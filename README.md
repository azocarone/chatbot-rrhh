# Chatbot de RR.HH

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![AI: Cohere](https://img.shields.io/badge/AI-Cohere-001F25?logo=cohere)](https://cohere.com/)
[![GitHub: Profile](https://img.shields.io/badge/GitHub-Profile-181717?logo=github)](https://github.com/)
[![Hosting: Railway](https://img.shields.io/badge/Hosting-Railway-131415?logo=railway)](https://railway.app/)
[![Automation: n8n](https://img.shields.io/badge/Automation-n8n-EA4B68?logo=n8n)](https://n8n.io/)
[![Telegram: Contact](https://img.shields.io/badge/Telegram-Contact-26A69A?logo=telegram)](https://t.me/)

## Tabla de Contenidos

- [Automatización con n8n](#-automatización-con-n8n)
- [Buenas Prácticas para Nombrar Flujos](#buenas-prácticas-para-nombrar-flujos)
- [Agente de IA Dentro del Workflow](#agente-de-ia-dentro-del-workflow)

## Automatización con n8n

n8n es una herramienta para conectar sistemas, y cuando se entiende la lógica detrás de sus componentes, se pasa de "copiar y pegar flujos" a diseñar arquitecturas de automatización robustas y eficientes.

Para dominar n8n, lo primero que se debe es desmitificar cómo estructurar mentalmente un flujo. Por lo tanto, se puede dividir el universo de n8n en cuatro pilares fundamentales:

### 1. Los Nodos (Nodes): Los bloques de construcción

Un nodo es la unidad básica de ejecución. Cada nodo realiza una acción específica (enviar un email, buscar en una base de datos, transformar un texto). Lo interesante es que todos comparten la misma anatomía conceptual:

- **Entrada (Input):** Recibe datos de los nodos anteriores (casi siempre en un formato estructurado).

- **Parámetros/Configuración:** Las instrucciones que se le proporciona al nodo (por ejemplo, a qué dirección enviar el correo).

- **Salida (Output):** El resultado de su ejecución, que pasa al siguiente bloque.

#### Tipos de Nodos según su función

- **Nodos de Integración (App Nodes):** Conectan con servicios externos (HubSpot, WhatsApp, OpenAI, Postgres) mediante sus APIs. n8n se encarga de la autenticación por detrás para que solo se llenen formularios.

- **Nodos de Core/Utilidades:** Son los que procesan la información *dentro* del flujo (Code, Set/Edit Fields, Filter, Switch). Son vitales para la lógica de negocio.

### 2. Triggers: El interruptor de encendido

Un flujo de trabajo (Workflow) no hace nada si nadie le dice cuándo empezar. Aquí entran los **Triggers** o disparadores. Son nodos especiales que inician la ejecución basándose en un evento:

- **Webhook Trigger:** Expone una URL pública. Cuando un sistema externo (como un formulario web o un CRM) envía datos a esa URL, el flujo se despierta al instante.

- **Schedule Trigger (Cron):** Ejecuta el flujo basándose en el tiempo (por ejemplo, "todos los lunes a las 8:00 AM" o "cada 5 minutos").

- **App Triggers (Polling vs. Webhook nativo):** Se activan cuando pasa algo en otra aplicación (ej. "Nueva fila en Google Sheets"). Algunos revisan cada cierto tiempo (Polling) y otros reaccionan en tiempo real.

### 3. El Modelo de Datos: JSON y la Estructura de "Items"

Este es el concepto que más suele costar al principio, pero es la clave de todo. **n8n piensa y habla en JSON.**

A diferencia de otras herramientas que pasan variables sueltas, n8n pasa siempre una **lista (Array) de objetos JSON**, a los que llama **Items**.

> **Regla de oro de n8n:** Si un nodo recibe una lista con 10 usuarios (10 items), el siguiente nodo intentará ejecutarse **10 veces de forma automática** (una vez para cada usuario), a menos que se usen nodos específicos para consolidar la información (como un *Aggregate* o un *Code* node).

Cada Item tiene una estructura predecible:

```json
[
  {
    "json": {
      "nombre": "Carlos",
      "email": "carlos@empresa.com"
    }
  }
]
```

### 4. Expresiones y Variables: El tejido conectivo

Para que los nodos sean dinámicos, no se pueden dejar valores fijos. Se usan **Expresiones** (basadas en JavaScript bajo el capó) para arrastrar datos de un nodo "A" a un nodo "B".

En las versiones modernas de n8n, la sintaxis utiliza `$json`:

- `{{ $json.email }}`: Accede al campo email del nodo inmediatamente anterior.

- `{{ $node["Clasificador"].json.intencion }}`: Accede de forma específica a un nodo del pasado llamado "Clasificador", sin importar cuántos nodos haya en el medio.

## Buenas Prácticas para Nombrar Flujos

Un buen nombre de workflow debe responder a tres preguntas de un solo vistazo:

1. **¿Qué tipo de flujo es o qué lo activa?** (Trigger / Categoría)

2. **¿Sobre qué entidad o sistema principal actúa?** (Entidad / Proyecto)

3. **¿Qué acción específica realiza?** (Acción)

La estructura ideal es:

`[CÓDIGO_PROYECTO o SISTEMA] - [TIPO/TRIGGER] - [Entidad]: [Acción concreta]`

**Glosario de Componentes**:

- **Sistema/Proyecto**: Identifica el cliente, departamento o el agente en sí (ej. `AGENTE_RH`, `MKT`, `CEREBRO`).

- **Tipo/Trigger**: Nos dice cómo nace el flujo. Ayuda a saber si es un sub-flujo (hijo) o un flujo principal (padre).

  - `SUB` o `CALL`: Flujos secundarios que se llaman con un nodo Execute Workflow.

  - `WEBHOOK` / `API`: Flujos que exponen un webhook para sistemas externos.

  - `CRON` / `SCHEDULE`: Flujos que se ejecutan por tiempo.

  - `CHATS` / `AI`: Flujos que interactúan directamente con interfaces de usuario o agentes de IA.

- **Entidad + Acción**: El qué y el cómo (ej. `Documento: Ingestar`, `Lead: Crear`).

### Ejemplos

Para un flujo que toma un documento y lo procesa envía a la memoria (base de datos vectorial, embeddings, etc.) del agente, aquí se tienen las mejores opciones dependiendo de cómo esté construido el ecosistema:

- **Opción A** (Si es un sub-flujo / la práctica más recomendada)

  > Normalmente, la ingesta es un proceso pesado que se aísla en un flujo hijo para reutilizarlo. Si es el caso, llamarlo así:

  `BRAIN - SUB - Documento: Ingestar a VectorDB`

- **Opción B** (Si se activa automáticamente cuando suben un archivo, ej. en Google Drive o S3)

  `BRAIN - CRON - Drive: Detectar e Ingestar Documentos`

- **Opción C** (Si el agente de IA lo hace en vivo mientras chatea con el usuario)

  `AGENTE - AI - Chat: Procesar e Ingestar Documento de Usuario`

### "Pro" Tips Extras

- **Usar verbos en infinitivo**: Mantener la consistencia usando siempre Ingestar, Crear, Actualizar, Enviar, en lugar de mezclar "Ingestión de...", "Creando...".

- **El poder del prefijo SUB -**: Cuando se creen flujos con el nodo `Execute Workflow`, empezar con `SUB -` permitirá escribir `SUB` en el buscador de n8n y ver instantáneamente todas las funciones reutilizables.

- **Cuidado con las mayúsculas**: n8n respeta las mayúsculas y minúsculas en el buscador. Definir si se usará `Title Case` (Mayúscula Al Principio de Cada Palabra) o `Sentence case` (Solo la primera) ahorrará fricciones.

## Agente de IA Dentro del Workflow

Para dominar los **AI Agents en n8n**, el secreto está en entender que no funcionan como un nodo tradicional de "acción". Por lo tanto, se desglosarán los conceptos clave y cómo se relacionan entre sí dentro de la interfaz:

### 1. El Cerebro del Flujo: El Nodo AI Agent

A diferencia de los nodos estándar, el nodo **AI Agent** en n8n actúa como un director de orquesta. En lugar de ejecutar una sola tarea lineal, se le proporciona un objetivo, un contexto y herramientas, y el agente decide cómo resolver el problema.

Para que este nodo funcione, requiere obligatoriamente estar conectado a otros sub-nodos (inputs) que definen su comportamiento.

### 2. Los 4 Pilares de un Agente en n8n

Para que un agente tenga sentido y no sea solo un chat vacío, n8n utiliza una arquitectura modular. Se debe imaginar que el nodo del agente tiene ranuras (slots) donde se le conectan cuatro componentes esenciales:

#### a. El Modelo de Lenguaje (Model)

Es el motor de inteligencia. n8n permite conectar proveedores como OpenAI, Anthropic, Mistral o Cohere, etc.

**Relación en el workflow**: El agente le envía el prompt y los datos al modelo para que este "piense" y genere la respuesta o decida qué herramienta usar.

#### b. La Memoria (Memory)

Por defecto, los LLMs no tienen memoria; cada mensaje es un lienzo en blanco. Si se está armando un bot de atención a cliente, se necesita que recuerde lo que el usuario dijo hace tres líneas.

**Relación en el workflow**: Conectar nodos como _Window Buffer Memory_ o memorias basadas en bases de datos (Redis, Chat Trigger Memory). Esto permite que el agente arrastre el historial de la conversación en cada iteración.

#### c. Las Herramientas (Tools)

Aquí es donde ocurre la magia de la automatización. Un LLM por sí solo solo sabe hablar. Las Tools le dan superpoderes para actuar en el mundo real.

**Relación en el workflow**: Se pueden conectar herramientas preconfiguradas (como buscar en Google, leer un Notion) o, lo mejor de todo, el nodo Workflow Tool. Este último te permite convertir cualquier otro flujo de n8n en una herramienta que el agente puede ejecutar cuando lo considere necesario (por ejemplo, registrar un usuario en una base de datos o verificar un email).

#### d. La Recuperación de Información (Information Retrieval / Vector Store)

Si se quiere que un agente responda preguntas sobre los manuales de tu empresa, políticas de Recursos Humanos o documentos específicos, no puede meter todo ese texto en el prompt porque saturaría el contexto.

**Relación en el workflow**: Se conectan nodos de Vector Store (como Pinecone, Qdrant o Supabase) junto con un Embeddings Content Retriever. El agente busca en esta base de datos el fragmento exacto de información que necesita para responder la pregunta del usuario.

#### 3. ¿Cómo interactúa el Agente con el resto de n8n?

El flujo de ejecución de un agente no es lineal, es cíclico (lo que en IA, se llama el bucle _Reasoning and Acting o ReAct_).

**Entrada**: Llega un trigger (por ejemplo, un webhook de WhatsApp o un chat en vivo).

**Evaluación**: El agente recibe el mensaje, consulta la Memoria para entender el contexto y le pregunta al Model: "¿Qué debo hacer para responder a esto?".

**Acción (Uso de Herramientas)**: Si el usuario pide "Verifica si mi correo está registrado", el agente detecta que tiene una Tool llamada `validar_email`. Detiene su respuesta, ejecuta la herramienta, va a la base de datos de n8n y regresa con el resultado.

**Respuesta Final**: El modelo procesa el resultado de la herramienta y genera la respuesta final que sale del nodo del agente hacia el usuario.
