# Approov QuickStart - Elixir Phoenix Absinthe GraphQL Token Check

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This repo implements the Approov server-side request verification code in [Elixir](https://elixir-lang.org/), which performs the verification check before allowing valid traffic to be processed by the GraphQL API endpoint.

This is an Approov integration quickstart example for the Elixir Phoenix framework. If you are looking for another Elixir integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/backend-api/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact).


## TOC - Table of Contents

* [Why?](#why)
* [How it Works?](#how-it-works)
* [Quickstarts](#approov-integration-quickstarts)
* [Examples](#approov-integration-examples)
* [Useful Links](#useful-links)


## Why?

You can learn more about Approov, the motives for adopting it, and more detail on how it works by following this [link](https://approov.io/product). In brief, Approov:

* Ensures that accesses to your GraphQL API come from official versions of your apps; it blocks accesses from republished, modified, or tampered versions
* Protects the sensitive data behind your GraphQL API; it prevents direct API abuse from bots or scripts scraping data and other malicious activity
* Secures the communication channel between your app and your GraphQL API with [Approov Dynamic Certificate Pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning). This has all the benefits of traditional pinning but without the drawbacks
* Removes the need for an API key in the mobile app
* Provides DoS protection against targeted attacks that aim to exhaust the GraphQL API server resources to prevent real users from reaching the service or to at least degrade the user experience.

[TOC](#toc---table-of-contents)


## How it works?

This is a brief overview of how the Approov cloud service and the Elixir Phoenix Absinthe GraphQL server fit together from a backend perspective. For a complete overview of how the mobile app and backend fit together with the Approov cloud service and the Approov SDK we recommend to read the [Approov overview](https://approov.io/product) page on our website.

### Approov Cloud Service

The Approov cloud service attests that a device is running a legitimate and tamper-free version of your mobile app.

* If the integrity check passes then a valid token is returned to the mobile app
* If the integrity check fails then a legitimate looking token will be returned

In either case, the app, unaware of the token's validity, adds it to every request it makes to the Approov protected GraphQL API(s).

### Elixir Phoenix Absinthe GraphQL Server

The Elixir Phoenix Absinthe GraphQL server ensures that the token supplied in the `Approov-Token` header is present and valid. The validation is done by using a shared secret known only to the Approov cloud service and the Elixir Phoenix Absinthe GraphQL server.

The request is handled such that:

* If the Approov Token is valid, the request is allowed to be processed by the GraphQL API endpoint
* If the Approov Token is invalid, an HTTP 401 Unauthorized response is returned

You can choose to log JWT verification failures, but we left it out on purpose so that you can have the choice of how you prefer to do it and decide the right amount of information you want to log.

>#### System Clock
>
>In order to correctly check for the expiration times of the Approov tokens is very important that the Phoenix backend server is synchronizing automatically the system clock over the network with an authoritative time source. In Linux this is usually done with a NTP server.

[TOC](#toc---table-of-contents)


## Approov Integration Quickstarts

The quickstart code for the Approov Elixir Phoenix Absinthe GraphQL server is split into two implementations. The first gets you up and running with basic token checking. The second uses a more advanced Approov feature, _token binding_. Token binding may be used to link the Approov token with other properties of the request, such as user authentication (more details can be found [here](https://approov.io/docs/latest/approov-usage-documentation/#token-binding)).
* [Approov token check quickstart](/docs/APPROOV_TOKEN_QUICKSTART.md)
* [Approov token check with token binding quickstart](/docs/APPROOV_TOKEN_BINDING_QUICKSTART.md)

Both the quickstarts are built from the unprotected example server defined in this Phoenix [project](/src/unprotected-server/todo).

You can use Git to see the code differences between the two quickstarts:

```
git diff --no-index src/approov-protected-server/token-check/todo/lib/approov_token.ex src/approov-protected-server/token-binding-check/todo/lib/approov_token.ex
```

[TOC](#toc---table-of-contents)


## Approov Integration Examples

The code examples for the Approov quickstarts are extracted from this simple [Approov integration examples](/src/approov-protected-server), that you can run from your computer to play around with the Approov integration and gain a better understanding of how simple and easy it is to integrate Approov in a Elixir Phoenix Absinthe GraphQL server.

### Testing with the Absinthe GraphiQL Web Interface

A ready-to-use GraphiQL workspace for each server can be found [here](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check/tree/master/graphiql). It contains a comprehensive set of example requests to send to the Elixir Phoenix Absinthe GraphQL server for testing. Choose the workspace for the server you are testing and upload it into the GraphiQL web interface. The workspaces for the Approov protected servers contains requests with valid and invalid Approov tokens, and with and without token binding.


### The Dummy Secret

The valid Approov tokens in the GraphiQL requests examples were signed with a dummy secret that was generated with `openssl rand -base64 64 | tr -d '\n'; echo`, therefore not a production secret retrieved with `approov secret -get base64url`, thus in order to use it you need to set the `APPROOV_BASE64URL_SECRET` environment variable on the backend server.

In the terminal execute:

```text
export APPROOV_BASE64URL_SECRET=h-CX0tOzdAAR9l15bWAqvq7w9olk66daIH-Xk-IAHhVVHszjDzeGobzNnqyRze3lw_WVyWrc2gZfh3XXfBOmww==
```

[TOC](#toc---table-of-contents)


## Useful Links

If you wish to explore the Approov solution in more depth, then why not try one of the following links as a jumping off point:

* [Approov Free Trial](https://approov.io/signup)(no credit card needed)
* [Approov QuickStarts](https://approov.io/docs/latest/approov-integration-examples/)
* [Approov Live Demo](https://approov.io/product/demo)
* [Approov Docs](https://approov.io/docs)
* [Approov Blog](https://blog.approov.io)
* [Approov Resources](https://approov.io/resource/)
* [Approov Customer Stories](https://approov.io/customer)
* [Approov Support](https://approov.zendesk.com/hc/en-gb/requests/new)
* [About Us](https://approov.io/company)
* [Contact Us](https://approov.io/contact)

[TOC](#toc---table-of-contents)
