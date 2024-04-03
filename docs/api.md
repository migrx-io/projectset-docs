# OpenAPI (Swagger)

**ProjectSet App**  exposes an OpenAPI interface so you can integrate it to your existing processes or integrate it with ChatBots and/or ServiceNow and etc.

## Authentication

ProjectSet App support service to service Authentication using API token. To enable it you should define Environment variable `X_API_KEY` for deployment.

From client side you should provide additinal header  `X-API-KEY: <token>`

```
curl -H 'X-API-KEY: <token>' https://<ProjectSet App Route>/

```

## OpenAPI (Swagger) 

!!swagger apispec_1.json!!
