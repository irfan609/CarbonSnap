const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const admin = require('firebase-admin');
const funtions = require('firebase-functions');

const serviceAccount = {
  "type": "service_account",
  "project_id": "lcos-app-2e724",
  "private_key_id": "d3188d31fb5cebd33d6df1e6bb6db52487d7b738",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQCyKj3z8Dv/VKZD\nHYrZFaTsTNXM51K7GkLm6V3A0cRqLUjOi59fZMX+hTdVWccKUmBqp9K63o/3OcRP\nWAK/OUXw09ox9QV3R1MrxkaR+yQtRu0V/2ghPMvPhvsYfqMgFOmS6hXo7YLw/g9k\nbyp5SYjtDj/pNjB7SXIVPYMncqrORGPUDsOUiEsjJ58E5HFQva6Pda2IuwM98kUb\npO26wJpBuS/F0GQhvbze5mB/aNfgqbSC8M3+BUmkOkU0wLWXgwJmFoGKuIsPR/84\nSj/hukvpuCUx746BB5H88vbMKenDFWT6MevebNbfMtrD1xovx9s1xGmgg3QhIXpF\n2c/Jqbc3AgMBAAECgf9qGsMp/tvGbd0FB15RqU54ZwOr6HwyD7qL95djHWIBz8QW\ndTOkj5koj0vLx5UuLpq/qMlhTq08QS1uqfkC3xGEYsTnRuQ+NqLvy9KkyGdmSU0g\nOJRkPAqEdqodno7X+EcEdmlt0/FIHCQ2vaNZPdjYCY3jOiPIieN42++hzV+qixHE\nMuJHd8JmzjDbLQoHa1a/3Ds8QVmUP/sZQl6aY35pg1loTxmecAgwWoXo31xfqKWG\nziZT8s3UGe4jaIAJav0Npvk5hQlgdIn0w3/cyJlZruLGs+M/or8YQwbK3qQof1J+\ntFErv83ntGMOlRaGb+886WHjJNXs+C5H8an64/kCgYEA25gXYJiQp/8XmtuAM9rB\n16V1eBuiHsZ5X4zUWflEKvBf6ls024uHk7utqd920xggIKEevTUjrZ/q1X42DQ1A\n9GdFD/cHypZeaX0gNAtEYolJSkFKewfLRfxTeZGq4m1PLqgGBpyVvKoULEUk+2ks\nsu/uavyCeSFRC3XkF4PyfR8CgYEAz7PWKTT18VthlAgEMhZX9/Mhzor7THzzeHjD\nm/AmdLj3GPiKUXHuk+DoRR85OTJKAB794zmL933owbPunQbZGaIEJpoOYHFFc9pl\nFmzPUL85gCNlhWgGwSMpqi1iugQJ0kcyL9d/9iCLOAX7em/CgNcfxdKDoH1miQ9k\na4n5aukCgYANdNR55t92a/tWUf0ZMF6QiGMaaRcWK7NkV4zrtoqm1vQJuG0UxwgX\n1Xhe4IK3jNLrLPRlQ8xb52DMlF9bjWRdlbZ1s/2WPICsli5TAh2+rAsBsd6Oi3u5\nXiz/Vh3SokAn68Pyw8WpOgLic5pAjcFfdbR2eeLE6XW97gt8JWnGoQKBgGj2SbDz\nSaKZ+nrTfkNNlVEBNkFpbMtfja6A4OFKADUWUBD3cPbtq5Jhox9jQwjLiCf9gXI1\n36zHnTteUaRbFJVmkdBsI/3K4D1GzbUCcdYtfMJroN9FDbzGp0SPwQeeCNSSFCOn\nNMxN7+z04PwjxFhV3oGa+9e753g2JhpOVJQZAoGAdzgyZ85DskbO5aOsH962XAEq\nXnYtKDuKMNyEdVWgE+9I11OjVsEErMuP8mjgpiYUcrB+0GHIBAXJKNk7WqK6YaC3\nK5OOyZVgFVve078fpUz5J2OjFalhDsrqyB+ZIvHZayhLXDoIzCPsrCPN77XZsQLE\naI/5ICOS7m5+UV6JQhs=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-bed0b@lcos-app-2e724.iam.gserviceaccount.com",
  "client_id": "114978187058541395802",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-bed0b%40lcos-app-2e724.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const app = express();

const _firestore = admin.firestore();
app.use(cors({ origin:true}));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());


var blogs = [
  {
    "title": "OCBC Bank to incorporate MGTC’S LCOS into transition financing plan",
    "image": "https://www.businesstoday.com.my/wp-content/uploads/2023/02/MGTC-OCBC.jpg",
    "desc": "OCBC Bank is set to become the first financial institution in the country to formulate specific plans....",
    "author": "The Star",
    "link": "https://www.thestar.com.my/business/business-news/2023/02/20/ocbc-bank-to-incorporate-mgtcs-lcos-into-transition-financing-plan"
  },
  {
    "title": "IGEM 2023 to feature over 10 conferences on race to net zero",
    "image": "https://mma.prnewswire.com/media/2239507/Deputy_Prime_Minister_Malaysia___IGEM_2023.jpg",
    "desc": "the International Greentech & Eco Products Exhibition & Conference Malaysia (IGEM) 2023 will host over 10 conferences from...",
    "author": "Bernama",
    "link" : "https://www.mgtc.gov.my/2023/09/igem-2023-to-feature-over-10-conferences-on-race-to-net-zero/"
  },
  {
    "title": "SPAN, water service operators to use LCOS system from next year",
    "image": "https://theedgemalaysia.com/_next/image?url=https%3A%2F%2Fassets.theedgemarkets.com%2Fwater-supply_123rf_46.jpg&w=1080&q=75",
    "desc": "The low carbon operating software (LCOS) system will be utilised in SPAN operations and...",
    "author": "The Edge Malaysia",
    "link" : "https://theedgemalaysia.com/node/690261"
  },
  {
    "title": "Malaysia’s Commitment on Climate Action And Preparations for (UNFCCC) COP28",
    "image": "https://www.mgtc.gov.my/wp-content/uploads/2023/10/Screenshot-2023-10-18-at-12.33.37%E2%80%AFPM.png",
    "desc": "Malaysia will also have a presence through a dedicated Malaysia Pavilion, which will showcase Malaysia’s thought leadership and...",
    "author": "PR News Wire",
    "link" : "https://www.prnewswire.co.uk/news-releases/malaysias-commitment-on-climate-action-and-preparations-for-the-united-nations-framework-convention-on-climate-change-unfccc-cop28-301950439.html"
  },
  {
    "title": "COP28: World leaders to address climate benchmark in Dubai",
    "image": "https://www.mgtc.gov.my/wp-content/uploads/2023/11/jabersd_1700013190.jpg",
    "desc": "The COP28 hosted by United Arab Emirates this year, will look at ways to set global temperature to 1.5 degrees Celcius...",
    "author": "Bernama",
    "link" : "https://www.nst.com.my/news/nation/2023/11/978447/cop28-world-leaders-address-climate-benchmark-dubai"
  },

  // Add more news as needed
  
]

var dailyTasks = {
  '1': 'Recycle 2 items',
  '2': 'Sleep without using air conditioner',
  '3': 'Use public transport',
};
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// tasks limited to 3
// 1 = task 1
// 1 = task 2
// 1 = Bonus task
// do not change the id number


const markers = [
  {
    title: 'Kudah 1.0',
    snippet: 'kutip dan riadah 1.0 (Taman Tasik Cempaka)',
    position: { latitude: 2.960344603086238, longitude: 101.75914163371685 },
    markerId: '1',
    category: 1,
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://bebasnews.my/wp-content/uploads/2021/12/266785936_10159982093414948_4189104450872057655_n.jpg','https://twitter.com/KASA_MALAYSIA/status/1554316764074217473/photo/1'],
    description: 'Acara kutip sampah sambil riadah (kudah) di BANGI Tasik Cempaka meriah.\n' + 
    'Selain mengutip sampah melebihi 100 plastik sampah, kami belajar tiga perkara penting:\n'+
    '1. Lebih 80% isipadu sampah yang dikutip adalah plastik pembungkusan makanan, minuman dll.\n'+
    '2. Walaupun air Sungai Air Hitam (anak Sungai Langat) jernih tetapi dari jauh kelihatan keruh. Ini kerana dasar sungai dan tasik dipenuhi keladak dan selut yang terhasil daripada aktiviti guna tanah dll dalam lembangan. Kekeruhan ini jika dikocak akan berbau disebabkan keladak dan selut mendak dan tertimbun dalam plastik dll sehingga menyebabkan keadaan anaerobik.\n'+
    '3. Pengunjung terbahagi dua: (a) Datang hanya untuk beriadah tanpa menghiraukan suasana dan kebersihan sungai atau tasik (b) Datang untuk menikmati keindahan dan kebersihan sungai dan tasik, di samping beriadah.',
  },
  {
    title: 'Gotong Royong Tasik',
    snippet: 'Gotong royong membersihkan tasik Titiwangsa',
    position: { latitude: 3.1778959511591167, longitude: 101.70719229149113 },
    markerId: '2',
    category: 1, 
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://ras.doe.gov.my/v2/wp-content/uploads/2020/12/poster-gotong-royong-768x767.jpg','https://ras.doe.gov.my/v2/wp-content/uploads/2020/12/ras6.jpg'],
    description: 'Team Rakan Alam Sekitar (RAS) Ibu Pejabat dan JAS Negeri Selangor telah turun padang bagi menjalankan aktiviti gotong royong di Sungai Klang berhampiran Taman Melawati.\n' + 
    'Aktiviti ini telah disambut baik dengan penglibatan NGOs dan penduduk di sekitar kawasan Taman Melawati. Menjaga kebersihan tidak mengira kawasan adalah tanggungjawab semua pihak, walaupun kita di dalam tempoh pandemik, penjagaan alam sekitar tidak harus di ambil ringgan. Pemiliharaan kebersihan alam yang  berimpak kecik ini akan menjadi besar sekiranya ianya terus dijalankan.\n'+
    'Ayuh kita menjaga kebersihan alam ini, ingat!! Alam Sekitar Tanggungjawab Bersama. Alam ini amanah tuhan pencipta, maka bersama lah kita membentuk ianya menjadi bumi yang indah dan ceria.\n',
  
  },
  {
    title: 'Pertunjukan Budaya Pelancongan Hainan',
    snippet: 'Pertunjukan Budaya Pelancongan Hainan China Berlangsung di Istana Budaya',
    position: { latitude: 3.177742802470303, longitude: 101.7072026173547 },
    markerId: '3',
    category: 2, 
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhwCSRviXXOvrUWafx8qBWh2_zndbx4XbKPet2gLsa11uf_UTGL1i8e_o_5qi74KQkfyzhW4kTUA-Gcq9hg4jNw4ZW0NlJLb2ead5JZVcWrrv0-dRIYAsYqN-7nScnVFZtRB_buhWygnCY2JRGZc0247Y63BYi73XiXGF6yhKODKXKK6Tn88XQx0xIr-w/w640-h364/Jom%20Melancong%20Ke%20Hainan%20China.JPG'],
    description: 'Hainan dan Malaysia merupakan kawasan kepulauan tropika yang berdekatan dan memiliki banyak sumber budaya pelancongan yang serupa. Aktiviti promosi ini memberi peluang kemasukan pelancong luar dengan dasar bebas visa masuk ke Hainan, menormalisasikan penerbangan sebagai logistik penghubungan, menggunakan pameran pelancongan MATTA FAIR Malaysia sebagai platform dan dengan memfokuskan pada sumber daya pelancongan yang umum, iaitu "Hutan Hujan Tropika" melalui acara-acara seperti memperkenalkan budaya kehidupan suku Li Miao dan promosi interaktif hutan hujan tropika. Ia juga turut menunjukkan konsep budaya pelancongan Hainan berkonsepkan "harmonis dengan alam" dan ake rah perkembangan positif pelancongan hijau.', 
    
  },
  {
    title: 'Sayangi Alam',
    snippet: 'Kempen terbuka kesedaran alam Putrajaya',
    position: { latitude: 2.914041198328738, longitude: 101.67944172874621 },
    markerId: '4',
    category: 2, 
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://www.ketengah.gov.my/wp-content/uploads/2023/03/337656804_2314424285383853_7770618965888106729_n.jpg','https://www.ketengah.gov.my/wp-content/uploads/2023/03/337531684_244595971249014_7780634154555692849_n.jpg'],
    description: 'Kempen Kesedaran Kebersihan Alam Sekitar Wilayah KETENGAH terus digerakkan dalam menjadikan lokasi tumpuan pelancong dijaga dan berfungsi dengan baik.\n' + 
    'Kawasan Rekreasi Pantai Floria, Putrajaya merupakan salah satu tempat tumpuan umum bagi aktiviti berkelah dan mandi-manda. Akan tetapi akibat daripada banjir yang melanda baru-baru ini, kemudahan tandas dan kawasan sekitar telah terjejas dan kotor.\n'+
    'Kempen ini akan diteruskan agar alam sekitar kita kekal bersih dan mendidik masyarakat supaya menjaga kebersihan, keharmonian dan kelestarian alam sekitar.\n',
  
  },
  {
    title: 'Kayuhan Bumi Hijau',
    snippet: 'Kayuhan basikal 10 KM terbuka Pantai Miami',
    position: { latitude: 5.370904425461333, longitude: 103.12270310852061 },
    markerId: '5',
    category: 3, 
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://ecoknights.org.my/wp-content/uploads/2021/10/KAYUHAN_HIJAU_AD_MAIN-1024x1024.png'],
    description: 'Sempena Sambutan Hari Alam Sekitar Negara (HASN) 2021 Peringkat Wilayah Persekutuan, EcoKnights mengajak anda semua untuk bersama-sama sertai program Kayuhan Hijau secara virtual!\n' + 
    'Anda boleh berbasikal di mana-mana lokasi di sekitar tempat tinggal anda dan mengumpul jumlah jarak kayuhan sejauh 25 kilometer. Maklumat lanjut adalah seperti yang tertera di poster di bawah.\n'+
    'Bagi setiap pendaftaran, anda akan diberi kit atau goodies menarik seperti jersi, medal, no. plat kayuhan, dan e-sijil! Bukan itu sahaja, perlindungan insuran juga tertakluk di bawah program kayuhan ini. Kit penyertaan ini akan dipos ke rumah anda secara percuma. \n',
  
  },
  {
    title: 'Larian Bumi Hijau',
    snippet: 'Larian 5 KM terbuka Tasik Perdana',
    position: { latitude: 3.143283527100414, longitude: 101.68482094960031 },
    markerId: '6',
    category: 3, 
    date:'12/12/2023',
    time:'8.30 am - 10.30am',
    photos: ['https://ecoknights.org.my/wp-content/uploads/2021/10/KAYUHAN_HIJAU_AD_MAIN-1024x1024.png'],
    description: 'Sempena Sambutan Hari Alam Sekitar Negara (HASN) 2021 Peringkat Wilayah Persekutuan, EcoKnights mengajak anda semua untuk bersama-sama sertai program Kayuhan Hijau secara virtual!\n' + 
    'Anda boleh berbasikal di mana-mana lokasi di sekitar tempat tinggal anda dan mengumpul jumlah jarak kayuhan sejauh 25 kilometer. Maklumat lanjut adalah seperti yang tertera di poster di bawah.\n'+
    'Bagi setiap pendaftaran, anda akan diberi kit atau goodies menarik seperti jersi, medal, no. plat kayuhan, dan e-sijil! Bukan itu sahaja, perlindungan insuran juga tertakluk di bawah program kayuhan ini. Kit penyertaan ini akan dipos ke rumah anda secara percuma. \n',
  
  },
  // Add more markers as needed
  // category
  // 1 = communal work
  // 2 = campaign and show
  // 3 = activity
  //makesure every marker have unique markerId
];


app.post('/calculate', (req, res) => {

  var carbonEmission = 2.33;
  var travel = 0.0;
  var diet = 0.0;
  var carTravel = 0.0;
  var fuel = 0.0;
  var shopping = 0.0;
  var homeSize = 0.0;
  var homePeople = 0.0;
  var pet = 0.0;

  var responses = req.body;

  for (var i = 0; i < Object.keys(responses).length; i++) {
    if (Object.keys(responses).length == 0) {
      break;
    }
    if (i == 0) {
      switch (responses[i]) {
        case 0:
          carbonEmission += 0.66;
          travel += 0.66;
          break;
        case 1:
          carbonEmission += 3.74;
          travel += 3.74;
          break;
        case 2:
          carbonEmission += 12.37;
          travel += 12.37;
          break;
        case 3:
          carbonEmission += 0;
          break;
        default:
          break;
      }
    } else if (i == 1) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 0.23;
          break;
        case 1:
          carbonEmission -= 0.16;
          break;
        case 2:
          carbonEmission -= 0.15;
          break;
        case 3:
          carbonEmission -= 0.06;
          diet += 0.06;
          break;
        case 4:
          carbonEmission += 0.08;
          diet += 0.08;
          break;
        default:
          break;
      }
    } else if (i == 2) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 0.42;
          break;
        case 1:
          carbonEmission += 0.07;
          carTravel += 0.07;
          break;
        case 2:
          carbonEmission += 1.04;
          carTravel += 1.04;
          break;
        case 3:
          carbonEmission += 2.03;
          carTravel += 2.03;
          break;
        case 4:
          carbonEmission += 3.49;
          carTravel += 3.49;
          break;
        default:
          break;
      }
    } else if (i == 3) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 0.18;
          break;
        case 1:
          carbonEmission -= 0.04;
          break;
        case 2:
          carbonEmission += 0.0;
          break;
        default:
          break;
      }
    } else if (i == 4) {
      switch (responses[i]) {
        case 0:
          carbonEmission += 0.18;
          shopping += 0.18;
          break;
        case 1:
          carbonEmission += 0.0;
          shopping += 0.0;
          break;
        case 2:
          carbonEmission += 3.26;
          shopping += 3.26;
          break;
        case 3:
          carbonEmission += 6.85;
          shopping += 6.85;
          break;
        default:
          break;
      }
    } else if (i == 5) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 0.29;
          break;
        case 1:
          carbonEmission -= 0.16;
          break;
        case 2:
          carbonEmission -= 0.04;
          break;
        case 3:
          carbonEmission += 0.09;
          homeSize += 0.09;
          break;
        case 4:
          carbonEmission += 1.69;
          homeSize += 1.69;
          break;
        default:
          break;
      }
    } else if (i == 6) {
      switch (responses[i]) {
        case 0:
          carbonEmission += 0.54;
          homePeople += 0.54;
          break;
        case 1:
          carbonEmission += 0.0;
          break;
        case 2:
          carbonEmission -= 0.19;
          break;
        case 3:
          carbonEmission -= 0.33;
          break;
        case 4:
          carbonEmission -= 0.39;
          break;
        default:
          break;
      }
    } else if (i == 7) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 0.05;
          break;
        case 1:
          carbonEmission += 0.25;
          pet += 0.25;
          break;
        case 2:
          carbonEmission += 0.35;
          pet += 0.35;
          break;
        case 3:
          carbonEmission += 0.11;
          pet += 0.11;
          break;
        default:
          break;
      }
    } else if (i == 8) {
      switch (responses[i]) {
        case 0:
          carbonEmission -= 1.1;
          break;
        case 1:
          carbonEmission += 0.05;
          fuel += 0.05;
          break;
        case 2:
          carbonEmission += 0.0;
          break;
        default:
          break;
      }
    }
  }

  carbonEmission = carbonEmission.toFixed(2);
  carbonEmission = Number(carbonEmission);

  var result = { "result": carbonEmission, "travel": travel, "diet": diet, "carTravel": carTravel, "fuel": fuel, "shopping": shopping, "homeSize": homeSize, "homePeople": homePeople, "pet": pet };
  res.send(result);
});


app.get('/marker', (req, res) => {
  const categorizedMarkers = markers.map((marker) => {
    let color;
    switch (marker.category) {
      case 1:
        color = 'green';
        break;
      case 2:
        color = 'yellow';
        break;
      case 3:
        color = 'blue';
        break;
      case 4:
        color = 'grey';
        break;
      default:
        color = 'white'; // Default color for unknown categories
        break;
    }
    return { ...marker, color };
  });

  res.json(categorizedMarkers);
});

app.get('/marker/:id', (req, res) => {
  const markerId = req.params.id;
  const marker = markers.find((m) => m.markerId === markerId);

  if (marker) {
    res.json(marker);
  } else {
    res.status(404).json({ error: 'Marker not found' });
  }
});


app.get('/dailyTasks', (req, res) => {
  res.json(dailyTasks);
});

app.post('/dailyTasks', (req, res) => {
  // Assuming you are sending an updated dailyTasks object in the request body
  const tasks = req.body;
  dailyTasks = tasks;
  res.send('Daily tasks updated successfully');
});

app.get('/blogs', (req, res) => {
  res.json(blogs);
});


//this part used to reset point daily
//then it will store the dailyPoint into firestore
const performDailyUpdate = async () => {
  try {
    console.log('Daily update started.');

    // Perform the daily update logic here
    const usersCollection = _firestore.collection('users');
    const usersSnapshot = await usersCollection.get();

    const today = new Date();
    const dayOfWeek = today.toLocaleDateString('en-US', { weekday: 'long' });

    usersSnapshot.forEach(async (userDoc) => {
      const userUid = userDoc.id;
      const userData = userDoc.data();

      // Get the 'point' value and store it in dailyPointValue
      const dailyPointValue = userData.point || 0;

      // Retrieve existing dailyPoint or create an empty object
      const existingDailyPoint = userData.dailyPoint || {};

      // Update the specific day in the dailyPoint map
      existingDailyPoint[dayOfWeek] = dailyPointValue;

      // Update the user document
      await usersCollection.doc(userUid).update({
        dailyPoint: existingDailyPoint,
        point: 0, // Reset 'point' to zero
      });
    });

    console.log('Daily update completed.');
  } catch (error) {
    console.error('Error during daily update:', error);
  }
};

app.get('/resetdaily', async (req, res) => {
  try {
    console.log('Resetting daily challenge via HTTP request.');
    await performDailyUpdate();
    res.status(200).send('Reset successful');  // Send a response to the Flutter app
  } catch (error) {
    console.error('Error during daily reset:', error);
    res.status(500).send('Internal Server Error');  // Send an error response to the Flutter app
  }
});


//this part used to copy value from weeklyPoint to lastWeekPoint
// then it will reset weeklyPoint and dailyPoint
const performWeeklyUpdate = async () => {
  try {
    console.log('Weekly update started.');

    const usersCollection = _firestore.collection('users');
    const usersSnapshot = await usersCollection.get();

    usersSnapshot.forEach(async (userDoc) => {
      const userUid = userDoc.id;
      const userData = userDoc.data();

      // Get the current weeklyPoint value
      const weeklyPointValue = userData.weeklyPoint || 0;

      // Update the 'lastWeekPoint' field with the current weeklyPoint value
      await usersCollection.doc(userUid).update({
        lastWeekPoint: weeklyPointValue,
      });

      // Reset 'weeklyPoint' and 'dailyPoint' to 0 and an empty object, respectively
      await usersCollection.doc(userUid).update({
        weeklyPoint: 0,
        dailyPoint: {},
      });
    });

    console.log('Weekly update completed.');
  } catch (error) {
    console.error('Error during weekly update:', error);
  }
};

app.get('/weeklyPoint', async (req, res) => {
  try {
    console.log('Resetting weekly challenge via HTTP request.');

    await performWeeklyUpdate();

    res.status(200).send('Reset successful');  // Send a response to the Flutter app
  } catch (error) {
    console.error('Error during weekly reset:', error);
    res.status(500).send('Internal Server Error');  // Send an error response to the Flutter app
  }
});

exports.app = funtions.https.onRequest(app);


