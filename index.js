import request from "request";
import querystring from "querystring";
import config from "./config";

export function handler (event, context, callback) {

    context.callbackWaitsForEmptyEventLoop = false; 

    // get params
    const params = querystring.parse(event.body);

    // make sure robot passes
    if (params.robot !== "7") {
        callback(new Error("Authorization failed")); 
    }

    const options = {
        method: 'POST',
        form: {
            ToBinding: `{"binding_type":"sms", "address":"${config.to}"}`,
            Body: `[${params.source}] ${params.name} (${params.email}) ${params.message}`,
        },
        headers: {
            "Authorization": "Basic " + new Buffer(config.accountSid + ':' + config.authToken).toString("base64")
        }
    }

    request(`https://notify.twilio.com/v1/Services/${config.notifySid}/Notifications`, options, (err, res, body) => {
        callback(null, {
            statusCode: "200",
            body: `<html><head><meta http-equiv="refresh" content="0; URL='${params.after}'" /></head></html>`,
            headers: {
                "Content-Type": "text/html",
            },
        });
    });
    
};
