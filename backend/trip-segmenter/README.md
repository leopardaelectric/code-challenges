<div align="center">

# 🏍️ Trip Segmenter — Vammo Backend Challenge

[![Status](https://img.shields.io/badge/status-active-brightgreen.svg)]()
[![Tech Stack](https://img.shields.io/badge/stack-any-blue.svg)]()
[![Difficulty](https://img.shields.io/badge/difficulty-medium-orange.svg)]()
[![Focus](https://img.shields.io/badge/focus-backend-lightgrey.svg)]()

A flexible backend challenge designed to evaluate problem-solving, trip segmentation logic, and clean system design.

</div>

---

## 📌 **Objective**

Build a small backend service that receives sequential **motorcycle pings** and groups them into **trips** based on movement and idleness.

You may use **any programming language, database, and architecture** you prefer.

---

## 🛰 **Input Data**

Each motorcycle ping contains:

- **License plate**
- **UNIX timestamp**
- **Coordinates**
- **Speed**
- **Odometer reading**

Pings always arrive **in order** for each motorcycle.

---

## 🧭 **Trip Logic (You Decide)**

You define:

- When a trip starts
- When a trip ends
- How long the motorcycle may remain idle before closing a trip
- How distance is computed (via odometer, GPS, or both)
- Whether to store raw pings or only derive summaries

Every trip must include at least:

- Start timestamp
- End timestamp
- Start and end coordinates
- Total distance (based on odometer)
- **Motorcycle license plate**

Anything beyond that is up to you.

---

## 📄 **Core Features**

### **1. Ingestion of Pings**

Your system must accept sequential pings for motorcycles (including the license plate).
The ingestion method is your choice:

- HTTP API
- Event/queue consumer
- File importer
- Scripted or mocked generator
- Anything else you prefer

---

### **2. Trip Listing (Paginated)**

Offer a way to list trips with basic pagination.

You decide:

- Pagination style (offset, cursor, page/size…)
- Ordering
- Optional filters (date range, license plate, etc.)

---

### **3. Trip Details**

Provide a minimal way to fetch details for a single trip, including the motorcycle’s **license plate**.

Format and schema are entirely open.

---

## 🎁 **Optional Bonus Features**

### ⭐ **Bonus A — Interactive Interface**

Create a small interface that interacts with your backend:

- CLI
- Mini web UI
- Scripts/playgrounds
- Postman/Insomnia collection

---

### ⭐ **Bonus B — Event-Driven Ingestion**

Implement an event-based ingestion flow via:

- Kafka, NATS, RabbitMQ, SQS, etc.
- File watcher
- Streaming consumer
- Webhooks

Mocked or simulated producers are fine.

---

### ⭐ **Bonus C — Trip Visualization**

Optional visual output, such as:

- Map with start/end
- Polyline drawn from raw pings
- ASCII-based map
- Any creative visualization

---

## 📬 **Delivery Instructions**

When you're finished:

1. Push your solution to a **public GitHub repository**.
2. Send the repository link to the email of the person who interviewed you.
