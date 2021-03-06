defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      flight_number: "",
      airport: "",
      matches: [],
      flights: [],
      loading: false
    )
    {:ok, socket, temporary_assigns: [flights: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="flight-search">
        <label for="flight_number">Flight number:</label>
        <input type="text" name="flight_number" value="<%= @flight_number %>"
              placeholder="Flight number"
              autofocus autocomplete="off"
              <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg" />
        </button>
      </form>
      <form phx-submit="airport-search" phx-change="suggest-airport">
        <label for="airport">Airport:</label>
        <input type="text" name="airport" value="<%= @airport %>"
              placeholder="Airport"
              autofocus autocomplete="off"
              list="matches"
              phx-debounce="250"
              <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
      <%= for match <- @matches do %>
        <option value="<%= match %>"><%= match %></option>
      <% end %>
      </datalist>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  <details>
                    <summary>Departs: <%= format_duration(flight.departure_time) %></summary>
                    <%= flight.departure_time %>
                  </details>
                </div>
                <div class="arrives">
                  <details>
                    <summary>Arrives: <%= format_duration(flight.arrival_time) %></summary>
                    <%= flight.arrival_time %>
                  </details>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("flight-search", %{"flight_number" => flight_number}, socket) do
    socket = assign(
      socket,
      flight_number: flight_number,
      loading: true, flights: []
    )
    send(self(), {:run_flight_number_search, flight_number})
    {:noreply, socket}
  end

  def handle_event("suggest-airport", %{"airport" => prefix}, socket) do
    socket = assign(socket, airport: prefix, matches: Airports.suggest(prefix))
    {:noreply, socket}
  end

  def handle_event("airport-search", %{"airport" => airport}, socket) do
    socket = assign(
      socket,
      airport: airport,
      loading: true, flights: []
    )
    send(self(), {:run_airport_search, airport})
    {:noreply, socket}
  end

  def handle_info({:run_flight_number_search, flight_number}, socket) do
    case Flights.search_by_number(flight_number) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching \"#{flight_number}\"")
          |> assign(flights: [], loading: false)
        {:noreply, socket}
      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)
        {:noreply, socket}
    end
  end

  def handle_info({:run_airport_search, airport}, socket) do
    case Flights.search_by_airport(airport) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching \"#{airport}\"")
          |> assign(flights: [], loading: false)
        {:noreply, socket}
      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)
        {:noreply, socket}
    end
  end
  def format_duration(time) do
    time
    |> Timex.diff(Timex.now())
    |> Timex.Duration.from_microseconds()
    |> Timex.format_duration(:humanized)
  end
end
