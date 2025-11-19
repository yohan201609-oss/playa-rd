import '../models/beach.dart';

class BeachService {
  // Base de datos completa de playas de República Dominicana
  // Fuente: Datos oficiales de turismo RD, coordenadas GPS verificadas
  static List<Beach> getDominicanBeaches() {
    return [
      // REGIÓN ESTE - PUNTA CANA Y LA ALTAGRACIA
      Beach(
        id: '1',
        name: 'Playa Bávaro',
        province: 'La Altagracia',
        municipality: 'Punta Cana',
        description:
            'Catalogada por UNESCO como una de las playas más hermosas del mundo. 40+ km de costa con arena blanca fina, aguas cristalinas color turquesa y oleaje suave a moderado. Zona turística desarrollada con infraestructura de primer nivel.',
        descriptionEn:
            'Listed by UNESCO as one of the most beautiful beaches in the world. 40+ km of coastline with fine white sand, crystal-clear turquoise waters and gentle to moderate waves. Developed tourist area with first-class infrastructure.',
        latitude: 18.6825,
        longitude: -68.4276,
        imageUrls: [],
        rating: 4.9,
        reviewCount: 5847,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Snorkel', 'Kayak', 'Buceo', 'Catamarán'],
      ),
      Beach(
        id: '2',
        name: 'Playa Macao',
        province: 'La Altagracia',
        municipality: 'Punta Cana',
        description:
            'Playa pública de 2 km con arena dorada y oleaje fuerte, perfecta para surf y bodyboard. Ambiente local auténtico, una de las playas públicas más hermosas y menos comercial que Bávaro.',
        descriptionEn:
            'Public beach of 2 km with golden sand and strong waves, perfect for surfing and bodyboarding. Authentic local atmosphere, one of the most beautiful and less commercial public beaches than Bávaro.',
        latitude: 18.7618,
        longitude: -68.4356,
        imageUrls: [],
        rating: 4.6,
        reviewCount: 1523,
        currentCondition: 'Bueno',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Surf', 'Natación', 'Voleibol'],
      ),
      Beach(
        id: '3',
        name: 'Playa Rincón',
        province: 'Samaná',
        municipality: 'Las Galeras',
        description:
            'Top 10 playas más bellas del mundo según Condé Nast Traveler. 3 km en forma de media luna con arena blanca, bosques de palmeras y Río Caño Frío. Un lado con aguas tranquilas, otro con olas.',
        descriptionEn:
            'Top 10 most beautiful beaches in the world according to Condé Nast Traveler. 3 km crescent-shaped with white sand, palm forests and Caño Frío River. One side with calm waters, the other with waves.',
        latitude: 19.2884,
        longitude: -69.2483,
        imageUrls: [],
        rating: 5.0,
        reviewCount: 4521,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Kayak', 'Caminata'],
      ),
      Beach(
        id: '4',
        name: 'Playa Juanillo',
        province: 'La Altagracia',
        municipality: 'Cap Cana',
        description:
            'Zona exclusiva de lujo con arena blanca finísima y aguas turquesas poco profundas. Una de las playas más románticas y exclusivas de RD. Incluye marina y campos de golf Jack Nicklaus.',
        descriptionEn:
            'Exclusive luxury area with finest white sand and shallow turquoise waters. One of the most romantic and exclusive beaches in the DR. Includes marina and Jack Nicklaus golf courses.',
        latitude: 18.4526,
        longitude: -68.3856,
        imageUrls: [],
        rating: 4.9,
        reviewCount: 2134,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Golf', 'Kayak'],
      ),
      Beach(
        id: '5',
        name: 'Isla Saona - Playa Palmilla',
        province: 'La Altagracia',
        municipality: 'Parque Nacional Cotubanamá',
        description:
            'Destino icónico del Caribe, una de las postales más famosas de RD. Varios kilómetros de arena blanca finísima, palmeras abundantes y aguas cristalinas. Parte del área protegida del Parque Nacional.',
        descriptionEn:
            'Iconic Caribbean destination, one of the most famous postcards of the DR. Several kilometers of finest white sand, abundant palm trees and crystal-clear waters. Part of the protected area of the National Park.',
        latitude: 18.1634,
        longitude: -68.7284,
        imageUrls: [],
        rating: 5.0,
        reviewCount: 6234,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': false,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Fotografía'],
      ),
      Beach(
        id: '6',
        name: 'Piscinas Naturales',
        province: 'La Altagracia',
        municipality: 'Isla Saona',
        description:
            'Bancos de arena únicos en varios km cuadrados. Profundidad de 0.5 a 1.5 metros, fondos arenosos, aguas transparentes con visibilidad hasta 30 metros. Estrellas de mar protegidas (prohibido tocarlas).',
        descriptionEn:
            'Unique sandbanks covering several square kilometers. Depth of 0.5 to 1.5 meters, sandy bottoms, transparent waters with visibility up to 30 meters. Protected starfish (touching them is prohibited).',
        latitude: 18.2145,
        longitude: -68.7542,
        imageUrls: [],
        rating: 5.0,
        reviewCount: 5234,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Snorkel', 'Natación', 'Fotografía'],
      ),
      Beach(
        id: '7',
        name: 'Playa Frontón',
        province: 'Samaná',
        municipality: 'Las Galeras',
        postalCode: '32000',
        description:
            'Playa virgen de difícil acceso pero paradisíaca. Solo accesible por bote (30 min) o trekking de 2 horas. Arena blanca rodeada de acantilados. Ideal para náufragos voluntarios.',
        descriptionEn:
            'Virgin beach difficult to access but paradisiacal. Only accessible by boat (30 min) or 2-hour trekking. White sand surrounded by cliffs. Ideal for voluntary castaways.',
        latitude: 19.29708,
        longitude: -69.15153,
        imageUrls: [],
        rating: 4.9,
        reviewCount: 1854,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Snorkel', 'Buceo', 'Aventura'],
      ),
      // REGIÓN NORTE - SAMANÁ
      Beach(
        id: '8',
        name: 'Playa El Valle',
        province: 'Samaná',
        municipality: 'Samaná',
        postalCode: '32000',
        description:
            'Playa salvaje de 5 km con arena dorada (diferente del resto), rodeada de montañas y bosque frondoso. Botes de colores pintorescos. Zona de desove de tortugas marinas.',
        descriptionEn:
            'Wild beach of 5 km with golden sand (different from the rest), surrounded by mountains and lush forest. Picturesque colorful boats. Sea turtle nesting area.',
        latitude: 19.2567,
        longitude: -69.3124,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 987,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Tortugas', 'Caminata'],
      ),
      Beach(
        id: '9',
        name: 'Cayo Levantado',
        province: 'Samaná',
        municipality: 'Samaná',
        description:
            'Postal clásica de Samaná, llamada "Isla Bacardí". Isla pequeña a 5 km de la costa con arena blanca, agua cristalina y vista panorámica de la península. Acceso por bote-taxi desde Avenida Marina.',
        descriptionEn:
            'Classic postcard of Samaná, called "Bacardí Island". Small island 5 km from the coast with white sand, crystal-clear water and panoramic view of the peninsula. Access by water taxi from Marina Avenue.',
        latitude: 19.1834,
        longitude: -69.3567,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 3521,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': false,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Fotografía'],
      ),
      // REGIÓN NORTE - SAMANÁ (LAS TERRENAS)
      Beach(
        id: '26',
        name: 'Playa Bonita',
        province: 'Samaná',
        municipality: 'Las Terrenas',
        description:
            'Playa de arena dorada, rodeada de palmeras, con un paseo marítimo, escuelas de surf y puestos de marisco.',
        descriptionEn:
            'Golden sand beach, surrounded by palm trees, with a boardwalk, surf schools and seafood stalls.',
        latitude: 19.3125,
        longitude: -69.5683333,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Natación', 'Surf', 'Paseo', 'Gastronomía'],
      ),
      Beach(
        id: '27',
        name: 'Playa Las Terrenas',
        province: 'Samaná',
        municipality: 'Las Terrenas',
        description: 'La playa central de Las Terrenas.',
        descriptionEn: 'The central beach of Las Terrenas.',
        latitude: 19.3232273,
        longitude: -69.5337249,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Paseo', 'Familias'],
      ),
      Beach(
        id: '28',
        name: 'Playa Las Ballenas',
        province: 'Samaná',
        municipality: 'Las Terrenas',
        description: 'Hermosa playa con aguas tranquilas, ideal para nadar.',
        descriptionEn: 'Beautiful beach with calm waters, ideal for swimming.',
        latitude: 19.3259609,
        longitude: -69.5515336,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Familias'],
      ),
      Beach(
        id: '29',
        name: 'Playa Punta Popy',
        province: 'Samaná',
        municipality: 'Las Terrenas',
        description:
            'Playa estrecha con aguas cristalinas, cocoteros y popular para el kitesurf.',
        descriptionEn:
            'Narrow beach with crystal-clear waters, coconut trees and popular for kitesurfing.',
        latitude: 19.3265358,
        longitude: -69.5285057,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Kitesurf', 'Windsurf', 'Natación'],
      ),
      Beach(
        id: '30',
        name: 'Punta Bonita',
        province: 'Samaná',
        municipality: 'Las Terrenas',
        description:
            'Playa flanqueada por palmeras con actividades acuáticas y cafeterías cercanas.',
        descriptionEn:
            'Beach flanked by palm trees with water activities and nearby cafes.',
        latitude: 19.3154721,
        longitude: -69.5750481,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Natación', 'Kayak', 'Gastronomía'],
      ),
      // REGIÓN SUR - PEDERNALES
      Beach(
        id: '10',
        name: 'Bahía de las Águilas',
        province: 'Pedernales',
        municipality: 'Pedernales',
        description:
            'La playa más remota y paradisíaca de RD. 8 km de playa virgen considerada la más cristalina del mundo. Paisaje kárstico sin desarrollo urbano. Parte del Parque Nacional Jaragua. Difícil acceso pero vale cada kilómetro.',
        descriptionEn:
            'The most remote and paradisiacal beach in the DR. 8 km of virgin beach considered the most crystal-clear in the world. Karst landscape without urban development. Part of Jaragua National Park. Difficult access but worth every kilometer.',
        latitude: 17.8945,
        longitude: -71.6234,
        imageUrls: [],
        rating: 5.0,
        reviewCount: 2654,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Ecoturismo', 'Fotografía'],
      ),
      // REGIÓN NORTE - PUERTO PLATA Y COSTA NORTE
      Beach(
        id: '11',
        name: 'Playa Dorada',
        province: 'Puerto Plata',
        municipality: 'Puerto Plata',
        description:
            'Uno de los primeros desarrollos turísticos de RD. 3 km de arena dorada (no blanca), oleaje moderado del Atlántico. Complejo turístico establecido con ambiente tradicional y campo de golf.',
        descriptionEn:
            'One of the first tourist developments in the DR. 3 km of golden sand (not white), moderate Atlantic waves. Established tourist complex with traditional atmosphere and golf course.',
        latitude: 19.7534,
        longitude: -70.6892,
        imageUrls: [],
        rating: 4.4,
        reviewCount: 2876,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Golf', 'Voleibol'],
      ),
      Beach(
        id: '12',
        name: 'Playa Sosúa',
        province: 'Puerto Plata',
        municipality: 'Sosúa',
        description:
            'Arena dorada en forma de media luna con aguas tranquilas protegidas. Arrecifes de coral, erizos y cuevas submarinas. Popular entre dominicanos y turistas, excelente para inmersiones.',
        descriptionEn:
            'Golden sand in crescent shape with protected calm waters. Coral reefs, sea urchins and underwater caves. Popular among Dominicans and tourists, excellent for diving.',
        latitude: 19.7512,
        longitude: -70.5123,
        imageUrls: [],
        rating: 4.6,
        reviewCount: 3432,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Snorkel', 'Buceo', 'Natación'],
      ),
      Beach(
        id: '13',
        name: 'Kite Beach',
        province: 'Puerto Plata',
        municipality: 'Cabarete',
        description:
            'Capital del kitesurf y windsurf del Caribe. Cuna del surf, kitesurf y windsurf con vientos fuertes constantes y olas ideales. La opción número uno por excelencia para deportes de viento en el Caribe.',
        descriptionEn:
            'Capital of kitesurfing and windsurfing in the Caribbean. Birthplace of surfing, kitesurfing and windsurfing with constant strong winds and ideal waves. The number one option par excellence for wind sports in the Caribbean.',
        latitude: 19.7567,
        longitude: -70.4156,
        imageUrls: [],
        rating: 4.9,
        reviewCount: 4256,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': true,
        },
        activities: ['Kitesurf', 'Windsurf', 'Surf'],
      ),
      // REGIÓN NOROESTE - MONTE CRISTI
      Beach(
        id: '14',
        name: 'Cayo Arena (Cayo Paraíso)',
        province: 'Montecristi',
        municipality: 'Punta Rucia',
        description:
            'Un paraíso flotante, banco de arena en medio del mar con aguas cristalinas poco profundas. Snorkel excepcional con barrera de coral. Mejor visitarlo temprano para evitar multitudes.',
        descriptionEn:
            'A floating paradise, sandbank in the middle of the sea with shallow crystal-clear waters. Exceptional snorkeling with coral barrier. Best visited early to avoid crowds.',
        latitude: 19.9234,
        longitude: -71.2456,
        imageUrls: [],
        rating: 5.0,
        reviewCount: 3765,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': true,
          'salvavidas': false,
        },
        activities: ['Snorkel', 'Natación', 'Fotografía'],
      ),
      Beach(
        id: '15',
        name: 'Punta Rucia',
        province: 'Montecristi',
        municipality: 'Villa Isabela',
        description:
            'Manglares abundantes, ambiente tranquilo. Punto de partida a Cayo Arena. Recomendado alojarse en Hostel Villa Rosa que incluye excursión temprana a Cayo Arena.',
        descriptionEn:
            'Abundant mangroves, tranquil atmosphere. Starting point to Cayo Arena. Recommended to stay at Hostel Villa Rosa which includes early excursion to Cayo Arena.',
        latitude: 19.8945,
        longitude: -71.2134,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 1234,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Ecoturismo', 'Kayak'],
      ),
      // REGIÓN ESTE - SANTO DOMINGO
      Beach(
        id: '16',
        name: 'Boca Chica',
        province: 'Santo Domingo',
        municipality: 'Boca Chica',
        address: 'C9WP+QRW, Boca Chica',
        description:
            'La playa de los capitalinos, muy frecuentada los fines de semana. Arena blanca con aguas calmadas protegidas por arrecife. Ambiente local auténtico a solo 30 km de Santo Domingo.',
        descriptionEn:
            "The beach of the capital's residents, very busy on weekends. White sand with calm waters protected by reef. Authentic local atmosphere just 30 km from Santo Domingo.",
        latitude: 18.4500,
        longitude: -69.6000,
        imageUrls: [],
        rating: 4.3,
        reviewCount: 4345,
        currentCondition: 'Bueno',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Snorkel', 'Jet Ski'],
      ),
      Beach(
        id: '17',
        name: 'La Caleta',
        province: 'Santo Domingo',
        municipality: 'La Caleta',
        description:
            'Excelente para buceo de todos los niveles con pecios submarinos. Famosa por el pescado frito y sitios de buceo de calidad. Cerca de Boca Chica.',
        descriptionEn:
            'Excellent for diving of all levels with underwater shipwrecks. Famous for fried fish and quality diving sites. Near Boca Chica.',
        latitude: 18.4312,
        longitude: -69.6845,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 2167,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Buceo', 'Snorkel', 'Gastronomía'],
      ),
      // REGIÓN SUR - BARAHONA
      Beach(
        id: '18',
        name: 'Playa San Rafael',
        province: 'Barahona',
        municipality: 'San Rafael',
        description:
            'Una de las playas más concurridas de Barahona. Famosa por la desembocadura del Río San Rafael que forma piscinas naturales de agua dulce y fría justo antes de unirse al mar Caribe. Aguas de color turquesa con oleaje a menudo fuerte, ideal para surfistas. La orilla está cubierta de pequeñas piedras blancas pulidas por el mar.',
        descriptionEn:
            'One of the most visited beaches in Barahona. Famous for the mouth of the San Rafael River that forms natural pools of fresh and cold water just before joining the Caribbean Sea. Turquoise waters with often strong waves, ideal for surfers. The shore is covered with small white stones polished by the sea.',
        latitude: 18.027413,
        longitude: -71.137610,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 892,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Río', 'Fotografía', 'Surf'],
      ),
      Beach(
        id: '21',
        name: 'Playa El Quemaíto',
        province: 'Barahona',
        municipality: 'Barahona',
        description:
            'Ubicada muy cerca de la ciudad de Barahona, es famosa por la claridad excepcional de sus aguas. Aguas de un impresionante color azul intenso y poco oleaje. La orilla está cubierta de pequeñas piedras blancas que producen un sonido particular con el vaivén del mar. Ideal para un día de sol y aguas templadas.',
        descriptionEn:
            'Located very close to the city of Barahona, it is famous for the exceptional clarity of its waters. Waters of an impressive deep blue color and little waves. The shore is covered with small white stones that produce a particular sound with the sway of the sea. Ideal for a day of sun and warm waters.',
        latitude: 18.121937,
        longitude: -71.068719,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 1245,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Fotografía', 'Relajación'],
      ),
      Beach(
        id: '22',
        name: 'Playa Los Patos',
        province: 'Barahona',
        municipality: 'Los Patos',
        description:
            'Punto donde el río Los Patos, considerado el río más corto del país, se encuentra con el mar. Hermosa playa con aguas cristalinas. Al igual que en San Rafael, el río forma un popular balneario natural de agua dulce cerca de la costa, perfecto para refrescarse.',
        descriptionEn:
            'Point where the Los Patos River, considered the shortest river in the country, meets the sea. Beautiful beach with crystal-clear waters. Like in San Rafael, the river forms a popular natural freshwater bathing area near the coast, perfect for cooling off.',
        latitude: 17.958771,
        longitude: -71.182427,
        imageUrls: [],
        rating: 4.6,
        reviewCount: 678,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Río', 'Familias', 'Fotografía'],
      ),
      Beach(
        id: '23',
        name: 'Playa Bahoruco',
        province: 'Barahona',
        municipality: 'La Ciénaga',
        description:
            'Destino principal para surfistas aficionados gracias a sus idílicas olas. Un retiro tranquilo con impresionantes puestas de sol. La Federación Dominicana de Surf ha organizado varios eventos en esta playa. Ideal para quienes buscan aventura en las olas del Caribe sur.',
        descriptionEn:
            'Main destination for amateur surfers thanks to its idyllic waves. A quiet retreat with impressive sunsets. The Dominican Surf Federation has organized several events on this beach. Ideal for those seeking adventure in the waves of the southern Caribbean.',
        latitude: 18.077800,
        longitude: -71.098518,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 534,
        currentCondition: 'Bueno',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Surf', 'Atardecer', 'Fotografía'],
      ),
      Beach(
        id: '24',
        name: 'Playa Saladilla',
        province: 'Barahona',
        municipality: 'Barahona',
        description:
            'Una de las principales playas de la zona, ideal para quienes buscan un ambiente más tranquilo y alejado del bullicio turístico. Perfecta para relajarse y disfrutar de la belleza natural del sur de República Dominicana.',
        descriptionEn:
            'One of the main beaches in the area, ideal for those seeking a quieter atmosphere away from tourist bustle. Perfect for relaxing and enjoying the natural beauty of southern Dominican Republic.',
        latitude: 18.1850,
        longitude: -71.0750,
        imageUrls: [],
        rating: 4.4,
        reviewCount: 312,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Tranquilidad', 'Ecoturismo'],
      ),
      Beach(
        id: '25',
        name: 'Playa Paraíso',
        province: 'Barahona',
        municipality: 'Paraíso',
        description:
            'Playa destacada en la provincia de Barahona, conocida por su belleza natural y ambiente tranquilo. Forma parte de la impresionante costa sur de la República Dominicana, ofreciendo paisajes espectaculares y aguas del Caribe.',
        descriptionEn:
            'Prominent beach in Barahona province, known for its natural beauty and tranquil atmosphere. Part of the impressive southern coast of the Dominican Republic, offering spectacular landscapes and Caribbean waters.',
        latitude: 18.0200,
        longitude: -71.1500,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 425,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Fotografía', 'Naturaleza'],
      ),
      Beach(
        id: '19',
        name: 'Playa Arena Gorda',
        province: 'La Altagracia',
        municipality: 'Punta Cana',
        description:
            'Una de las playas más amplias de RD, ideal para reclamar sombra bajo palmeras. Arena blanca muy amplia con pendiente suave y aguas cristalinas. Certificación Bandera Azul en múltiples sectores.',
        descriptionEn:
            'One of the widest beaches in the DR, ideal for claiming shade under palm trees. Very wide white sand with gentle slope and crystal-clear waters. Blue Flag certification in multiple sectors.',
        latitude: 18.7345,
        longitude: -68.4156,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 3876,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Familias', 'Deportes'],
      ),
      Beach(
        id: '20',
        name: 'Uvero Alto',
        province: 'La Altagracia',
        municipality: 'Punta Cana',
        description:
            'Alternativa más exclusiva y menos concurrida que Bávaro. Zona menos desarrollada con ambiente más tranquilo. Arena blanca en resorts boutique con menor densidad turística.',
        descriptionEn:
            'More exclusive and less crowded alternative than Bávaro. Less developed area with quieter atmosphere. White sand at boutique resorts with lower tourist density.',
        latitude: 18.8254,
        longitude: -68.4892,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 2187,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Tranquilidad', 'Parejas'],
      ),
      // REGIÓN SUR - AZUA
      Beach(
        id: '31',
        name: 'Playa Palmar de Ocoa',
        province: 'Azua',
        municipality: 'Las Charcas - Palmar de Ocoa',
        description:
            'De aguas tranquilas y cristalinas, en la Bahía de Ocoa. Es conocida por sus hermosos atardeceres y la presencia de embarcaciones.',
        descriptionEn:
            'With calm and crystal-clear waters, in Ocoa Bay. Known for its beautiful sunsets and the presence of boats.',
        latitude: 18.255,
        longitude: -70.683,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Atardecer', 'Fotografía'],
      ),
      Beach(
        id: '32',
        name: 'Playa Monte Río',
        province: 'Azua',
        municipality: 'Azua de Compostela',
        description:
            'Una de las playas cercanas al centro urbano de Azua, utilizada como punto de partida para visitar otras playas.',
        descriptionEn:
            'One of the beaches near the urban center of Azua, used as a starting point to visit other beaches.',
        latitude: 18.3348,
        longitude: -70.7909,
        imageUrls: [],
        rating: 4.3,
        reviewCount: 0,
        currentCondition: 'Bueno',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Familias'],
      ),
      Beach(
        id: '33',
        name: 'Playa La Caobita',
        province: 'Azua',
        municipality: 'Azua de Compostela',
        description:
            'Conocida por su arena blanca y agua cristalina, tiene un arrecife natural que funciona como rompeolas, manteniendo el agua muy serena (como una piscina).',
        descriptionEn:
            'Known for its white sand and crystal-clear water, it has a natural reef that acts as a breakwater, keeping the water very calm (like a pool).',
        latitude: 18.3056,
        longitude: -70.7147,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Familias'],
      ),
      Beach(
        id: '34',
        name: 'Playa El Barco',
        province: 'Azua',
        municipality: 'Azua',
        description:
            'Hermosa playa de arena blanca y agua muy cristalina, considerada un tesoro virgen, a menudo solo accesible por bote o 4x4.',
        descriptionEn:
            'Beautiful beach with white sand and very crystal-clear water, considered a virgin treasure, often only accessible by boat or 4x4.',
        latitude: 18.3118,
        longitude: -70.685,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Aventura', 'Ecoturismo'],
      ),
      Beach(
        id: '35',
        name: 'Playa Uvita',
        province: 'Azua',
        municipality: 'Azua',
        description: 'Una de las playas mencionadas en la costa de Azua.',
        descriptionEn: 'One of the beaches mentioned on the Azua coast.',
        latitude: 18.3234,
        longitude: -70.75,
        imageUrls: [],
        rating: 4.4,
        reviewCount: 0,
        currentCondition: 'Bueno',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Tranquilidad'],
      ),
      // REGIÓN NORTE - MARÍA TRINIDAD SÁNCHEZ
      Beach(
        id: '36',
        name: 'Playa Grande',
        province: 'María Trinidad Sánchez',
        municipality: 'Río San Juan',
        description:
            'Una de las más largas y hermosas de la costa norte, conocida por su arena dorada y su fuerte oleaje, ideal para surf. Está bordeada por cocoteros.',
        descriptionEn:
            'One of the longest and most beautiful on the north coast, known for its golden sand and strong waves, ideal for surfing. It is bordered by coconut trees.',
        latitude: 19.6284,
        longitude: -70.015,
        imageUrls: [],
        rating: 4.8,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Surf', 'Natación', 'Fotografía'],
      ),
      Beach(
        id: '37',
        name: 'Playa Caletón',
        province: 'María Trinidad Sánchez',
        municipality: 'Río San Juan',
        description:
            'Ubicada en Río San Juan, es más pequeña y tranquila, con aguas cristalinas y un ambiente relajante. Ideal para un baño refrescante.',
        descriptionEn:
            'Located in Río San Juan, it is smaller and quieter, with crystal-clear waters and a relaxing atmosphere. Ideal for a refreshing swim.',
        latitude: 19.6667,
        longitude: -70.033,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Snorkel', 'Relajación'],
      ),
      Beach(
        id: '38',
        name: 'Playa La Entrada',
        province: 'María Trinidad Sánchez',
        municipality: 'Cabrera - La Entrada',
        description:
            'Un auténtico paraíso natural cerca de Cabrera, menos concurrida, rodeada de vegetación.',
        descriptionEn:
            'An authentic natural paradise near Cabrera, less crowded, surrounded by vegetation.',
        latitude: 19.5531,
        longitude: -69.9467,
        imageUrls: [],
        rating: 4.6,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Ecoturismo', 'Tranquilidad'],
      ),
      Beach(
        id: '39',
        name: 'Playa Preciosa',
        province: 'María Trinidad Sánchez',
        municipality: 'Río San Juan',
        description:
            'A corta distancia de Playa Grande (unos 500m al este). Destaca por su belleza natural y vistas impresionantes.',
        descriptionEn:
            'A short distance from Playa Grande (about 500m east). Stands out for its natural beauty and impressive views.',
        latitude: 19.6287,
        longitude: -70.0089,
        imageUrls: [],
        rating: 4.7,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Fotografía', 'Caminata'],
      ),
      Beach(
        id: '40',
        name: 'Playa Arroyo Salado',
        province: 'María Trinidad Sánchez',
        municipality: 'Cabrera',
        description:
            'Una playa donde desemboca un río, ofreciendo la singularidad de tener playa y río en el mismo lugar. Es más visitada por locales.',
        descriptionEn:
            'A beach where a river flows, offering the uniqueness of having beach and river in the same place. It is more visited by locals.',
        latitude: 19.4633,
        longitude: -69.8234,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': true,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Río', 'Naturaleza'],
      ),
      // REGIÓN SUR - PERAVIA
      Beach(
        id: '41',
        name: 'Playa Las Salinas',
        province: 'Peravia',
        municipality: 'Baní - Las Calderas',
        description:
            'Famosa por la península que forma la Bahía de Las Calderas y por sus minas de sal (Laguna de El Salado del Muerto). Su arena tiene un color oscuro.',
        descriptionEn:
            'Famous for the peninsula that forms Las Calderas Bay and for its salt mines (Laguna de El Salado del Muerto). Its sand has a dark color.',
        latitude: 18.2499,
        longitude: -70.5099,
        imageUrls: [],
        rating: 4.4,
        reviewCount: 0,
        currentCondition: 'Bueno',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Fotografía', 'Ecoturismo'],
      ),
      Beach(
        id: '42',
        name: 'Playa Nizao',
        province: 'Peravia',
        municipality: 'Nizao',
        description:
            'Una playa semivirgen y poco visitada, con olas suaves y costa de arena con piedras. Ofrece paz y hermosos atardeceres.',
        descriptionEn:
            'A semi-virgin and little-visited beach, with gentle waves and sandy coast with stones. Offers peace and beautiful sunsets.',
        latitude: 18.2633,
        longitude: -70.1864,
        imageUrls: [],
        rating: 4.5,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Atardecer', 'Tranquilidad'],
      ),
      Beach(
        id: '43',
        name: 'Playa Los Corbanitos',
        province: 'Peravia',
        municipality: 'Baní - Sabana Buey',
        description:
            'Una playa de arena marrón claro, con potencial desarrollo turístico, ubicada en una zona tranquila.',
        descriptionEn:
            'A beach with light brown sand, with potential tourist development, located in a quiet area.',
        latitude: 18.228,
        longitude: -70.6282,
        imageUrls: [],
        rating: 4.2,
        reviewCount: 0,
        currentCondition: 'Bueno',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': false,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Tranquilidad'],
      ),
      Beach(
        id: '44',
        name: 'Playa Sombrero',
        province: 'Peravia',
        municipality: 'Baní - Sombrero',
        description:
            'Ubicada en un entorno natural atractivo, con vegetación resistente a la sequía.',
        descriptionEn:
            'Located in an attractive natural environment, with drought-resistant vegetation.',
        latitude: 18.3747,
        longitude: -70.4542,
        imageUrls: [],
        rating: 4.3,
        reviewCount: 0,
        currentCondition: 'Bueno',
        amenities: {
          'baños': false,
          'duchas': false,
          'parking': true,
          'restaurantes': false,
          'sombrillas': false,
          'salvavidas': false,
        },
        activities: ['Natación', 'Naturaleza', 'Ecoturismo'],
      ),
      Beach(
        id: '45',
        name: 'Playa Punta Arena',
        province: 'Peravia',
        municipality: 'Baní - Punta Calderas',
        description:
            'Una playa que cuenta con infraestructura turística, como un club de playa y terrazas, con arena blanca.',
        descriptionEn:
            'A beach that has tourist infrastructure, such as a beach club and terraces, with white sand.',
        latitude: 18.2633,
        longitude: -70.5627,
        imageUrls: [],
        rating: 4.6,
        reviewCount: 0,
        currentCondition: 'Excelente',
        amenities: {
          'baños': true,
          'duchas': true,
          'parking': true,
          'restaurantes': true,
          'sombrillas': true,
          'salvavidas': true,
        },
        activities: ['Natación', 'Familias', 'Club de Playa'],
      ),
    ];
  }

  // Filtrar playas por provincia
  static List<Beach> filterByProvince(List<Beach> beaches, String province) {
    if (province.isEmpty || province == 'Todas') {
      return beaches;
    }
    return beaches.where((beach) => beach.province == province).toList();
  }

  // Filtrar playas por condición
  static List<Beach> filterByCondition(List<Beach> beaches, String condition) {
    if (condition.isEmpty || condition == 'Todas') {
      return beaches;
    }
    return beaches
        .where((beach) => beach.currentCondition == condition)
        .toList();
  }

  // Buscar playas por nombre
  static List<Beach> searchBeaches(List<Beach> beaches, String query) {
    if (query.isEmpty) {
      return beaches;
    }
    return beaches
        .where(
          (beach) =>
              beach.name.toLowerCase().contains(query.toLowerCase()) ||
              beach.province.toLowerCase().contains(query.toLowerCase()) ||
              beach.municipality.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Ordenar playas
  static List<Beach> sortBeaches(List<Beach> beaches, String sortBy) {
    List<Beach> sorted = List.from(beaches);
    switch (sortBy) {
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'condition':
        // Ordenar por severidad: Excelente > Bueno > Moderado > Peligroso > Desconocido
        sorted.sort((a, b) {
          int priorityA = _getConditionPriority(a.currentCondition);
          int priorityB = _getConditionPriority(b.currentCondition);
          return priorityA.compareTo(priorityB);
        });
        break;
      default:
        break;
    }
    return sorted;
  }

  // Obtener prioridad de condición (menor número = mejor condición)
  static int _getConditionPriority(String condition) {
    switch (condition) {
      case 'Excelente':
        return 1;
      case 'Bueno':
        return 2;
      case 'Moderado':
        return 3;
      case 'Peligroso':
        return 4;
      default:
        return 5; // Desconocido
    }
  }
}
