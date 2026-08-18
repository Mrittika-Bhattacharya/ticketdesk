const API_BASE = "/prod/api";

const ticketForm = document.getElementById("ticket-form");
const ticketsContainer = document.getElementById("tickets");
const refreshButton = document.getElementById("refresh-button");
const formMessage = document.getElementById("form-message");


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

    data.tickets.forEach((ticket) => {
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

      ticketsContainer.appendChild(ticketElement);
    });
  } catch (error) {
    console.error(error);
    ticketsContainer.innerHTML =
      '<p class="error">Unable to load tickets.</p>';
  }
}


async function createTicket(event) {
  event.preventDefault();

  formMessage.textContent = "";

  const formData = new FormData(ticketForm);

  const ticket = {
    title: formData.get("title"),
    description: formData.get("description"),
    priority: formData.get("priority"),
    status: formData.get("status")
  };

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
      throw new Error(data.detail || `Failed to create ticket: ${response.status}`);
    }

    formMessage.textContent = data.message || "Ticket created successfully.";

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