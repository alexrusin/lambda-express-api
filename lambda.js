const serverlessExpress = require("@vendia/serverless-express");
const { createServer } = require("./dist/server.js");

exports.handler = serverlessExpress({ app: createServer() });
