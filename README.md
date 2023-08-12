# Texting service 

The purpose of this API is to receive a message and sen send it with external SMS service providers. It has a simple and
straightforward load balancer to equally distribute the load between providers. It also has a simple retry mechanism
implemented with Sidekiq.
 
## Setup and run

This application uses [Docker Compose](https://docs.docker.com/compose/) for services. The idea is that a rails app is 
running locally, but all the services are running in containers. Setup and startup process is automated with `Makefile`
and [Foreman](https://github.com/theforeman/foreman).

To setup, install docker, then run
```shell
  make build
```

To run the application
```shell
  make up
```

Or if you want to run it in separate terminal tabs
```shell
  docker-compose up
  bin/dev
```

## Run tests

```shell
  rails test
```

## Project structure

### DB layer
I used Postgres as a database. It has built-in ENUM type, which is very convenient for storing statuses. I also used 
AASM gem to implement messages status logic.

```mermaid
  erDiagram
    PhoneNumber {
      bigint id PK
      uuid public_id
      string number
      enum status
    }
  
    Message {
      bigint id PK
      uuid public_id
      string message_body
      enum status
      uuid provider_id
      bigint phone_number_id FK
      uuid provider_id
    }
  
  PhoneNumber ||--|{ Message:has_many
```


### How it works
When API receives a message, it finds or creates a PhoneNumber record in DB. If PhoneNumber record has `active` state, 
it creates a message record in DB and enqueues a job to send it with one of the providers. When message is sent, provider
sends a delivery status to the API. API finds a message by provider_id and updates its status. If status is `invalid`, 
corresponding phone number is marked as `inactive`.

```mermaid
  sequenceDiagram
    participant Client
    participant MessagesController
    participant MessageCreatorService
    participant DB
    participant SmsProviderRequestJob
    participant SmsProvider
    participant MessageDeliveryStatusService
    
    Client->>MessagesController: POST /messages
    MessagesController->>MessageCreatorService: calls with message params 
    MessageCreatorService->>DB: finds/creates phone number, creates message
    MessageCreatorService-->>DB: finds phone number, does nothing if it's inactive
    MessageCreatorService->>SmsProviderRequestJob: enqueues job with message data
    SmsProviderRequestJob->>SmsProvider: POSTs message data to one of the urls
    SmsProviderRequestJob->>DB: updates provider_id of sent message
    SmsProvider->>MessagesController: POST /messages/delivery_status
    MessagesController->>MessageDeliveryStatusService: calls with message delivery status params
    MessageDeliveryStatusService->>DB: finds message by provider_id, updates status
    MessageDeliveryStatusService->>DB: if status is 'invalid', updates phone number status to 'inactive'
```


