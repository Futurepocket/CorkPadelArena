const admin = require("firebase-admin");
const functions = require("firebase-functions");
admin.initializeApp();
const { getDatabase } = require("firebase-admin/database");

// Get a database reference to our blog
const db = getDatabase();
let mistake;
let query;

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

exports.checkPayment = functions.https.onCall((req, context) => {
  const https = require("https");
  query = req;
let numberOfRequests = 1;
let success = false;
  //requestMbWay(query.idPedido)
  return new Promise(async (resolve, reject) => {
    const MbWayKey = "PDY-214580";
    const canal = "03";
    const url =
      "https://www.ifthenpay.com/mbwayws/ifthenpaymbw.asmx/EstadoPedidosJSON?MbWayKey=" +
      MbWayKey +
      "&canal=" +
      canal +
      "&idspagamento=" +
      query.idPedido;
    while (numberOfRequests < 30 && success == false) {
      const request = https
        .request(url, (response) => {
          let data = "";
          response.on("data", (chunk) => {
            data = data + chunk.toString();
          });
          response.on("end", () => {
            try {
              const body = JSON.parse(data);
              console.log("Promise worked");
              if (body.EstadoPedidos[0].Estado == "000") {
                success = true;
                // Fazer update à Reserva
                //const reservations = database.ref("/reservations");
                const database = admin.firestore();
                query.reservationsToCheckOut.forEach((element) => {
                  db.ref("/reservations/" + element["id"]).update({
                    //reservations.doc(element["id"]).update( {
                    state: "pago",
                    completed: true,
                  });
                  console.log("reservations complete");
                });
                //for (const element in query.reservationsToCheckOut) {
                //}
                try {
                  // Send Email to client
                  database
                    .collection("reservationEmails")
                    .add(query.clientEmailToCloud);
                } catch (e) {
                  //throw new HttpsError(e);
                  console.log(e.message);
                  mistake = 3;
                  // return 3;
                }
                try {
                  // Send Email to Company
                  database
                    .collection("reservationEmails")
                    .add(query.companyEmailToCloud);
                } catch (e) {
                  console.log(e.message);
                  mistake = 4;
                  // return 4;
                }
                try {
                  // Save Payment
                  database
                    .collection("MBWayPayments")
                    .doc(query.idd)
                    .set(query.payment);
                } catch (e) {
                  console.log(e.message);
                  mistake = 5;
                  // return 5;
                }
                mistake = 0;
                resolve(body);
                numberOfRequests = 10;
              } else {
                console.log("if não funcionou");
                mistake = 6;
                // return 6;
              }
            } catch (e) {
              console.log("Promise didn't work");
              reject(e.message);
            }
          });
        })
        .on("error", (e) => {
          console.log("Promise didn't work 2:" + e.message);
          reject(e.message);
        });
      request.end();
      numberOfRequests++;
      await sleep(10000);
    }
  })
    .then((response) => {
      return mistake;
    })
    .catch((error) => {
      console.log(error.message);
      mistake = 7;
      return 7;
    });

  //request.end();
  //request.on('error', (error) => {
  //    console.log('An error', error);
  //});
  //json = request.end();

});


// function requestMbWay(idPedido) {
//   const https = require("https");

//   return new Promise((resolve, reject) => {
//     const MbWayKey = "PDY-214580";
//     const canal = "03";
//     const url =
//       "https://www.ifthenpay.com/mbwayws/ifthenpaymbw.asmx/EstadoPedidosJSON?MbWayKey=" +
//       MbWayKey +
//       "&canal=" +
//       canal +
//       "&idspagamento=" +
//       idPedido;
//     const request = https
//       .request(url, (response) => {
//         let data = "";
//         response.on("data", (chunk) => {
//           data = data + chunk.toString();
//         });
//         response.on("end", () => {
//           try {
//             const body = JSON.parse(data);
//             console.log("Promise worked");
//             resolve(body);
//           } catch (e) {
//             console.log("Promise didn't work");
//             reject(e.message);
//           }
//         });
//       })
//       .on("error", (e) => {
//         console.log("Promise didn't work 2:" + e.message);
//         reject(e.message);
//       });
//     request.end();
//   });
// }