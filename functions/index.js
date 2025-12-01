/**
 * Cloud Functions para Playas RD
 * Implementación de funcionalidades serverless para la app
 */

// Cargar variables de entorno desde .env (solo para desarrollo local)
require("dotenv").config();

const {setGlobalOptions} = require("firebase-functions");
const {
  onDocumentUpdated,
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onObjectFinalized} =
  require("firebase-functions/v2/storage");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const sharp = require("sharp");
const axios = require("axios");
const nodemailer = require("nodemailer");

const SUPPORT_EMAIL = "soporteplayasrd@outlook.com";

const getSupportEmailConfig = () => {
  // Leer de variables de entorno (configuradas en Firebase Functions)
  // Para Firebase Functions v2, usar functions.config() de v1
  const functionsV1 = require("firebase-functions");
  let config = {};
  try {
    config = functionsV1.config();
  } catch (e) {
    // Si no está disponible, usar process.env
    logger.warn("functions.config() no disponible, usando process.env");
  }

  const user = (config.support && config.support.email_user) ||
               process.env.SUPPORT_EMAIL_USER ||
               "soporteplayasrd@outlook.com";
  const pass = (config.support && config.support.email_pass) ||
               process.env.SUPPORT_EMAIL_PASS;

  return {
    user,
    pass,
    host: (config.support && config.support.smtp_host) ||
          process.env.SUPPORT_SMTP_HOST ||
          "smtp.office365.com",
    port: Number((config.support && config.support.smtp_port) ||
                 process.env.SUPPORT_SMTP_PORT ||
                 587),
    // Outlook usa STARTTLS (587) no SSL directo
    secure: ((config.support &&
              config.support.smtp_secure === "true") ||
             process.env.SUPPORT_SMTP_SECURE === "true") || false,
    requireTLS: true, // Requerir TLS para Outlook
  };
};

// Inicializar Firebase Admin
admin.initializeApp();

// Configuración global para control de costos
setGlobalOptions({maxInstances: 10});

// =============================================================================
// 1. 🔔 NOTIFICACIONES PUSH - Cuando cambie condición de playa
// =============================================================================

/**
 * Envía notificaciones push a usuarios cuando cambia la condición de una playa
 * que tienen en favoritos
 */
exports.notifyBeachConditionChange = onDocumentUpdated(
    {
      document: "beaches/{beachId}",
      region: "us-central1",
    },
    async (event) => {
      try {
        const beforeData = event.data.before.data();
        const afterData = event.data.after.data();
        const beachId = event.params.beachId;

        // Verificar si cambió la condición
        if (beforeData.condition === afterData.condition) {
          logger.info("Condición sin cambios, no se envía notificación");
          return null;
        }

        const beachName = afterData.name || "Una playa";
        const oldCondition = beforeData.condition || "Desconocida";
        const newCondition = afterData.condition || "Desconocida";

        logger.info(
            `Condición de ${beachName} cambió de ` +
            `${oldCondition} a ${newCondition}`,
        );

        // Obtener usuarios que tienen esta playa en favoritos
        const usersSnapshot = await admin
            .firestore()
            .collection("users")
            .where("favoriteBeaches", "array-contains", beachId)
            .get();

        if (usersSnapshot.empty) {
          logger.info("No hay usuarios con esta playa en favoritos");
          return null;
        }

        // Preparar tokens de notificación
        const tokens = [];
        usersSnapshot.forEach((doc) => {
          const userData = doc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length === 0) {
          logger.info("No hay tokens FCM disponibles");
          return null;
        }

        // Determinar emoji según condición
        const conditionEmoji = {
          "Excelente": "🏖️",
          "Bueno": "✅",
          "Moderado": "⚠️",
          "Peligroso": "🚫",
        };

        // Enviar notificaciones
        const message = {
          notification: {
            title: `${conditionEmoji[newCondition] || "🌊"} ` +
              `Actualización de ${beachName}`,
            body: `La condición cambió de ${oldCondition} ` +
              `a ${newCondition}`,
          },
          data: {
            beachId: beachId,
            condition: newCondition,
            type: "beach_condition_change",
          },
          tokens: tokens,
        };

        const response = await admin
            .messaging().sendEachForMulticast(message);
        logger.info(
            `Enviadas ${response.successCount} notificaciones de ` +
            `${tokens.length} intentos`,
        );

        return response;
      } catch (error) {
        logger.error("Error enviando notificaciones:", error);
        return null;
      }
    },
);

// =============================================================================
// 2. 🖼️ PROCESAMIENTO DE IMÁGENES - Redimensionar y comprimir
// =============================================================================

/**
 * Procesa automáticamente las imágenes subidas:
 * - Crea una versión optimizada (1200px ancho)
 * - Crea un thumbnail (400px ancho)
 * - Comprime las imágenes para ahorrar espacio
 */
exports.processUploadedImage = onObjectFinalized(
    {
      bucket: "playas-rd-2b475.firebasestorage.app",
      region: "us-central1",
    },
    async (event) => {
      try {
        const filePath = event.data.name;
        const contentType = event.data.contentType;

        // Verificar que sea una imagen
        if (!contentType || !contentType.startsWith("image/")) {
          logger.info("No es una imagen, se omite procesamiento");
          return null;
        }

        // Evitar procesar imágenes ya procesadas
        if (filePath.includes("_optimized") || filePath.includes("_thumb")) {
          logger.info("Imagen ya procesada, se omite");
          return null;
        }

        // Solo procesar imágenes de reportes
        if (!filePath.startsWith("reports/")) {
          logger.info("No es una imagen de reporte, se omite");
          return null;
        }

        logger.info(`Procesando imagen: ${filePath}`);

        const bucket = admin.storage().bucket(event.data.bucket);
        const fileName = filePath.split("/").pop();
        const fileNameWithoutExt = fileName.replace(/\.[^/.]+$/, "");
        const fileExt = fileName.split(".").pop();

        // Descargar imagen original
        const tempFilePath = `/tmp/${fileName}`;
        await bucket.file(filePath).download({destination: tempFilePath});

        // Crear versión optimizada (1200px)
        const optimizedPath = `/tmp/${fileNameWithoutExt}_optimized.${fileExt}`;
        await sharp(tempFilePath)
            .resize(1200, null, {
              fit: "inside",
              withoutEnlargement: true,
            })
            .jpeg({quality: 85, progressive: true})
            .toFile(optimizedPath);

        // Crear thumbnail (400px)
        const thumbPath = `/tmp/${fileNameWithoutExt}_thumb.${fileExt}`;
        await sharp(tempFilePath)
            .resize(400, 400, {
              fit: "cover",
              position: "center",
            })
            .jpeg({quality: 80, progressive: true})
            .toFile(thumbPath);

        // Subir versión optimizada
        const optimizedDestination = filePath.replace(
            fileName,
            `${fileNameWithoutExt}_optimized.${fileExt}`,
        );
        await bucket.upload(optimizedPath, {
          destination: optimizedDestination,
          metadata: {
            contentType: "image/jpeg",
            metadata: {
              originalImage: filePath,
            },
          },
        });

        // Subir thumbnail
        const thumbDestination = filePath.replace(
            fileName,
            `${fileNameWithoutExt}_thumb.${fileExt}`,
        );
        await bucket.upload(thumbPath, {
          destination: thumbDestination,
          metadata: {
            contentType: "image/jpeg",
            metadata: {
              originalImage: filePath,
            },
          },
        });

        logger.info("Imágenes procesadas exitosamente");
        logger.info(`Optimizada: ${optimizedDestination}`);
        logger.info(`Thumbnail: ${thumbDestination}`);

        return {
          original: filePath,
          optimized: optimizedDestination,
          thumbnail: thumbDestination,
        };
      } catch (error) {
        logger.error("Error procesando imagen:", error);
        return null;
      }
    },
);

// =============================================================================
// 3. 🧹 LIMPIEZA AUTOMÁTICA - Reportes antiguos (cada día a las 2 AM)
// =============================================================================

/**
 * Limpia reportes de playas con más de 30 días de antigüedad
 * Se ejecuta automáticamente todos los días a las 2:00 AM
 */
exports.cleanupOldReports = onSchedule(
    {
      schedule: "0 2 * * *", // Diario a las 2 AM
      timeZone: "America/Santo_Domingo",
      region: "us-central1",
    },
    async (event) => {
      try {
        logger.info("Iniciando limpieza de reportes antiguos...");

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // Buscar reportes antiguos
        const reportsSnapshot = await admin
            .firestore()
            .collection("reports")
            .where("createdAt", "<", thirtyDaysAgo)
            .get();

        if (reportsSnapshot.empty) {
          logger.info("No hay reportes antiguos para eliminar");
          return null;
        }

        logger.info(
            `Se encontraron ${reportsSnapshot.size} reportes antiguos`,
        );

        // Eliminar reportes en lotes de 500 (límite de Firestore)
        const batch = admin.firestore().batch();
        let deletedCount = 0;

        reportsSnapshot.forEach((doc) => {
          batch.delete(doc.ref);
          deletedCount++;
        });

        await batch.commit();

        logger.info(`✅ Se eliminaron ${deletedCount} reportes antiguos`);

        // Registrar en una colección de logs (opcional)
        await admin.firestore().collection("maintenance_logs").add({
          type: "cleanup_old_reports",
          deletedCount: deletedCount,
          executedAt: admin.firestore.FieldValue.serverTimestamp(),
          threshold: thirtyDaysAgo,
        });

        return {
          deleted: deletedCount,
          threshold: thirtyDaysAgo.toISOString(),
        };
      } catch (error) {
        logger.error("Error limpiando reportes:", error);
        return null;
      }
    },
);

// =============================================================================
// 4. 🌤️ SINCRONIZACIÓN CON API DE CLIMA - Actualizar cada 6 horas
// =============================================================================

/**
 * Actualiza automáticamente los datos del clima
 * para todas las playas
 * Se ejecuta cada 6 horas usando OpenWeatherMap API
 * NOTA: Necesitas configurar la API key en Firebase Config
 */
exports.updateBeachWeather = onSchedule(
    {
      schedule: "0 */6 * * *", // Cada 6 horas
      timeZone: "America/Santo_Domingo",
      region: "us-central1",
    },
    async (event) => {
      try {
        logger.info(
            "Iniciando actualización de clima para " +
            "todas las playas...",
        );

        // Obtener la API key de OpenWeatherMap desde Firebase Config
        // Configúrala con:
        // firebase functions:config:set weather.api_key="TU_API_KEY"
        const weatherApiKey = process.env.WEATHER_API_KEY;

        if (!weatherApiKey) {
          logger.error(
              "⚠️ API key de OpenWeatherMap no configurada. " +
            "Usa: firebase functions:config:set weather.api_key='TU_API_KEY'",
          );
          return null;
        }

        // Obtener todas las playas con coordenadas
        const beachesSnapshot = await admin
            .firestore()
            .collection("beaches")
            .get();

        if (beachesSnapshot.empty) {
          logger.info("No hay playas para actualizar");
          return null;
        }

        logger.info(
            `Actualizando clima para ${beachesSnapshot.size} playas`,
        );

        let successCount = 0;
        let errorCount = 0;

        // Procesar cada playa
        for (const beachDoc of beachesSnapshot.docs) {
          const beachData = beachDoc.data();
          const {coordinates, name} = beachData;

          // Verificar que tenga coordenadas
          if (!coordinates ||
              !coordinates.latitude ||
              !coordinates.longitude) {
            logger.warn(`Playa ${name} sin coordenadas, se omite`);
            continue;
          }

          try {
            // Llamar a OpenWeatherMap API
            const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?` +
                `lat=${coordinates.latitude}&lon=${coordinates.longitude}` +
                `&appid=${weatherApiKey}&units=metric&lang=es`;

            const response = await axios.get(weatherUrl);
            const weatherData = response.data;

            // Preparar datos del clima
            const weatherInfo = {
              temperature: Math.round(weatherData.main.temp),
              feelsLike: Math.round(weatherData.main.feels_like),
              humidity: weatherData.main.humidity,
              description: weatherData.weather[0].description,
              icon: weatherData.weather[0].icon,
              windSpeed: weatherData.wind.speed,
              cloudiness: weatherData.clouds.all,
              lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            };

            // Actualizar documento de la playa
            await beachDoc.ref.update({
              weather: weatherInfo,
            });

            successCount++;
            logger.info(`✅ Clima actualizado para ${name}`);
          } catch (error) {
            errorCount++;
            logger.error(
                `❌ Error actualizando clima para ${name}:`,
                error.message,
            );
          }

          // Pequeña pausa para no saturar la API (si tienes muchas playas)
          await new Promise((resolve) => setTimeout(resolve, 100));
        }

        const summary = {
          total: beachesSnapshot.size,
          success: successCount,
          errors: errorCount,
          timestamp: new Date().toISOString(),
        };

        logger.info(
            `📊 Resumen: ${successCount} éxitos, ${errorCount} errores`,
        );

        // Registrar en logs
        await admin.firestore().collection("maintenance_logs").add({
          type: "weather_sync",
          ...summary,
          executedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return summary;
      } catch (error) {
        logger.error("Error sincronizando clima:", error);
        return null;
      }
    },
);

// =============================================================================
// 🎯 FUNCIÓN ADICIONAL: Notificar cuando se crea un nuevo reporte
// =============================================================================

/**
 * Notifica a usuarios cercanos cuando alguien hace un reporte de playa
 */
exports.notifyNewReport = onDocumentCreated(
    {
      document: "reports/{reportId}",
      region: "us-central1",
    },
    async (event) => {
      try {
        const reportData = event.data.data();
        const reportId = event.params.reportId;

        logger.info(`Nuevo reporte creado: ${reportId}`);

        // Obtener información de la playa
        const beachRef = admin
            .firestore()
            .collection("beaches")
            .doc(reportData.beachId);
        const beachDoc = await beachRef.get();

        if (!beachDoc.exists) {
          logger.warn("Playa no encontrada");
          return null;
        }

        const beachData = beachDoc.data();

        // Obtener usuarios que tienen esta playa en favoritos
        const usersSnapshot = await admin
            .firestore()
            .collection("users")
            .where("favoriteBeaches", "array-contains", reportData.beachId)
            .get();

        if (usersSnapshot.empty) {
          logger.info("No hay usuarios interesados en esta playa");
          return null;
        }

        // Preparar tokens
        const tokens = [];
        usersSnapshot.forEach((doc) => {
          const userData = doc.data();
          // No notificar al usuario que creó el reporte
          if (userData.fcmToken && doc.id !== reportData.userId) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length === 0) {
          logger.info("No hay tokens para notificar");
          return null;
        }

        // Enviar notificación
        const message = {
          notification: {
            title: `📢 Nuevo reporte en ${beachData.name}`,
            body: reportData.comment ||
              "Alguien reportó las condiciones de la playa",
          },
          data: {
            beachId: reportData.beachId,
            reportId: reportId,
            type: "new_report",
          },
          tokens: tokens,
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        logger.info(`Enviadas ${response.successCount} notificaciones`);

        return response;
      } catch (error) {
        logger.error("Error notificando nuevo reporte:", error);
        return null;
      }
    },
);

/**
 * Envía un correo al equipo cuando un usuario envía soporte
 */
exports.processSupportRequest = onDocumentCreated(
    {
      document: "support_requests/{requestId}",
      region: "us-central1",
    },
    async (event) => {
      const supportConfig = getSupportEmailConfig();

      // Log para debugging (sin mostrar la contraseña completa)
      logger.info("Configuración SMTP:", {
        user: supportConfig.user,
        host: supportConfig.host,
        port: supportConfig.port,
        secure: supportConfig.secure,
        passLength: supportConfig.pass ? supportConfig.pass.length : 0,
        passPrefix: supportConfig.pass ?
          supportConfig.pass.substring(0, 5) + "..." : "undefined",
      });

      if (!supportConfig.user || !supportConfig.pass) {
        logger.error(
            "Credenciales de correo para soporte no configuradas. " +
            "Configura SUPPORT_EMAIL_USER y SUPPORT_EMAIL_PASS.",
        );
        logger.error("Variables de entorno disponibles:", {
          SUPPORT_EMAIL_USER: process.env.SUPPORT_EMAIL_USER || "undefined",
          SUPPORT_EMAIL_PASS: process.env.SUPPORT_EMAIL_PASS ?
            "***" + process.env.SUPPORT_EMAIL_PASS.substring(
                process.env.SUPPORT_EMAIL_PASS.length - 5,
            ) : "undefined",
        });
        return null;
      }

      const transporter = nodemailer.createTransport({
        host: supportConfig.host,
        port: supportConfig.port,
        // false para puerto 587 (STARTTLS), true para 465 (SSL)
        secure: supportConfig.secure,
        requireTLS: supportConfig.requireTLS || false,
        auth: {
          user: supportConfig.user,
          pass: supportConfig.pass,
        },
        authMethod: "PLAIN", // Especificar método de autenticación
        tls: {
          // No rechazar certificados no autorizados (útil para desarrollo)
          rejectUnauthorized: false,
          ciphers: "SSLv3", // Forzar compatibilidad
        },
        // Configuración adicional para Outlook
        connectionTimeout: 10000, // 10 segundos
        greetingTimeout: 10000,
        socketTimeout: 10000,
      });

      try {
        const requestId = event.params.requestId;
        const data = event.data.data();

        const subject = data.type === "suggestion" ?
          "Nueva sugerencia desde Playas RD" :
          "Nuevo reporte de problema desde Playas RD";

        const htmlBody = `
          <h2>${subject}</h2>
          <p><strong>Mensaje:</strong></p>
          <p>${(data.message || "").replace(/\n/g, "<br>")}</p>
          <hr />
          <p><strong>Contacto:</strong> ${data.contact || "No provisto"}</p>
          <p><strong>Usuario:</strong> ${data.userEmail || "Anónimo"}</p>
          <p><strong>Nombre:</strong> ${data.userDisplayName || "N/A"}</p>
          <p><strong>Plataforma:</strong> ${data.platform || "Desconocida"}</p>
          <p><strong>ID de solicitud:</strong> ${requestId}</p>
        `;

        await transporter.sendMail({
          // Para SendGrid, el remitente debe ser el email verificado
          from: `"Playas RD Soporte" <${SUPPORT_EMAIL}>`,
          to: SUPPORT_EMAIL,
          subject: `${subject} · ${requestId}`,
          html: htmlBody,
          text: `
${subject}

Mensaje:
${data.message || ""}

Contacto: ${data.contact || "No provisto"}
Usuario: ${data.userEmail || "Anónimo"}
Nombre: ${data.userDisplayName || "N/A"}
Plataforma: ${data.platform || "Desconocida"}
ID: ${requestId}
          `,
        });

        await event.data.ref.update({
          status: "sent",
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        logger.info(`Soporte procesado y enviado para ${requestId}`);
        return null;
      } catch (error) {
        logger.error("Error enviando correo de soporte:", error);
        await event.data.ref.update({
          status: "error",
          error: error.message,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }
    },
);
