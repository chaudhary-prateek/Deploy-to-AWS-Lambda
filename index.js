exports.handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Hi from Lambda in a Docker container! deploy v1.0.1" }),
  };
};