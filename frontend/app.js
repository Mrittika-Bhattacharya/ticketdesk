const API_BASE = "/prod/api";

const ticketForm = document.getElementById("ticket-form");
const ticketsContainer = document.getElementById("tickets");
const refreshButton = document.getElementById("refresh-button");
const formMessage = document.getElementById("form-message");
const attachmentInput = document.getElementById("attachment");

/*
 * Stores attachment filenames for tickets created during
 * the current browser session.
 *
 * Example:
 * {
 *   13: "screenshot.png"
 * }
 */
const ticketAttachments = new Map();

async function loadTickets() {
  ticketsContainer.textContent = "Loading...";

  try {
    const response = await fetch(`${API_BASE}/tickets`);

    if (!response.ok) {
      throw new Error(`Failed to load tickets: ${response.status}`);
    }

    const data = await response.json();

    if (!data.tickets || data.tickets.length === 0) {
      ticketsContainer.textContent = "No tickets found.";
      return;
    }

    ticketsContainer.innerHTML = "";

    for (const ticket of data.tickets) {
      const ticketElement = document.createElement("article");
      ticketElement.className = "ticket";

      ticketElement.innerHTML = `
        <h3>${escapeHtml(ticket.title)}</h3>
        <p>${escapeHtml(ticket.description)}</p>
        <p>
          <strong>Priority:</strong> ${escapeHtml(ticket.priority)}
          <br>
          <strong>Status:</strong> ${escapeHtml(ticket.status)}
        </p>
      `;

      const attachmentFilename = ticketAttachments.get(ticket.id);

      if (attachmentFilename) {
        try {
          const thumbnailUrl = await getThumbnailUrl(
            ticket.id,
            attachmentFilename
          );

          if (thumbnailUrl) {
            const attachmentSection = document.createElement("div");
            attachmentSection.className = "ticket-attachment";

            attachmentSection.innerHTML = `
              <strong>Attachment:</strong>
              <br>
              <img
                src="${thumbnailUrl}"
                alt="Attachment thumbnail for ${escapeHtml(ticket.title)}"
                class="thumbnail"
              >
            `;

            ticketElement.appendChild(attachmentSection);
          }
        } catch (error) {
          console.error(
            `Unable to load thumbnail for ticket ${ticket.id}`,
            error
          );
        }
      }

      ticketsContainer.appendChild(ticketElement);
    }
  } catch (error) {
    console.error(error);

    ticketsContainer.innerHTML =
      '<p class="error">Unable to load tickets.</p>';
  }
}

async function uploadAttachment(ticketId, file) {
  const query = new URLSearchParams({
    filename: file.name,
    content_type: file.type
  });

  const urlResponse = await fetch(
    `${API_BASE}/tickets/${ticketId}/attachments/presigned-url?${query}`,
    {
      method: "POST"
    }
  );

  const urlData = await urlResponse.json();

  if (!urlResponse.ok) {
    throw new Error(
      urlData.detail ||
      `Failed to get upload URL: ${urlResponse.status}`
    );
  }

  const uploadResponse = await fetch(urlData.upload_url, {
    method: "PUT",
    headers: {
      "Content-Type": file.type
    },
    body: file
  });

  if (!uploadResponse.ok) {
    throw new Error(
      `S3 upload failed: ${uploadResponse.status} ${uploadResponse.statusText}`
    );
  }

  return urlData.key;
}

async function getThumbnailUrl(ticketId, filename) {
  const query = new URLSearchParams({
    filename
  });

  const response = await fetch(
    `${API_BASE}/tickets/${ticketId}/attachments/thumbnail-url?${query}`
  );

  const data = await response.json();

  if (response.ok && data.ready && data.thumbnail_url) {
    return data.thumbnail_url;
  }

  return null;
}

async function waitForThumbnail(
  ticketId,
  filename,
  maxAttempts = 20
) {
  for (
    let attempt = 0;
    attempt < maxAttempts;
    attempt += 1
  ) {
    const thumbnailUrl = await getThumbnailUrl(
      ticketId,
      filename
    );

    if (thumbnailUrl) {
      return thumbnailUrl;
    }

    await new Promise(
      (resolve) => setTimeout(resolve, 1500)
    );
  }

  throw new Error(
    "Thumbnail was not ready within the expected time."
  );
}

async function createTicket(event) {
  event.preventDefault();

  formMessage.textContent = "";
  formMessage.className = "";

  const formData = new FormData(ticketForm);

  const ticket = {
    title: formData.get("title"),
    description: formData.get("description"),
    priority: formData.get("priority"),
    status: formData.get("status")
  };

  const file = attachmentInput.files[0] || null;

  try {
    const response = await fetch(`${API_BASE}/tickets`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(ticket)
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(
        data.detail ||
        `Failed to create ticket: ${response.status}`
      );
    }

    const ticketId = data.ticket.id;

    if (file) {
      formMessage.textContent =
        "Ticket created. Uploading screenshot...";

      await uploadAttachment(ticketId, file);

      ticketAttachments.set(ticketId, file.name);

      formMessage.textContent =
        "Screenshot uploaded. Generating thumbnail...";

      const thumbnailUrl = await waitForThumbnail(
        ticketId,
        file.name
      );

      formMessage.innerHTML = `
        Ticket created successfully.
        <br>
        <img
          src="${thumbnailUrl}"
          alt="Generated attachment thumbnail"
          class="thumbnail"
        >
      `;
    } else {
      formMessage.textContent =
        data.message ||
        "Ticket created successfully.";
    }

    ticketForm.reset();

    await loadTickets();
  } catch (error) {
    console.error(error);

    formMessage.textContent = error.message;
    formMessage.className = "error";
  }
}

function escapeHtml(value) {
  const div = document.createElement("div");

  div.textContent = value ?? "";

  return div.innerHTML;
}

ticketForm.addEventListener("submit", createTicket);
refreshButton.addEventListener("click", loadTickets);

loadTickets();
