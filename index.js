const http = require("http");
const {
  Elm: { Server }
} = require("./elm.js");

const app = Server.init();

http
  .createServer((request, res) => {
    new Promise(resolve =>  app.ports.onRequest.send({ request, resolve }))
      .then(({ status, response }) => {
        res.statusCode = status;
        res.end(response);
      });
  })
  .listen(3000);

app.ports.resolve.subscribe(([{ resolve }, status, response]) => {
  resolve({ status, response });
});
