defmodule LiveViewStudioWeb.AutocompleteLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Stores
  alias LiveViewStudio.Cities

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        zip: "",
        city: "",
        matches: [],
        stores: [],
        loading: false
      )
    {:ok, socket, temporary_assigns: [stores: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Store</h1>
    <div id="search">

    <form phx-submit="zip-search">
        <input type="text" name="zip" value="<%= @zip %>"
               placeholder="Zip Code"
               autofocus autocomplete="off"
               <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg" />
        </button>
      </form>

      <form phx-submit="city-search" phx-change="suggest-city">
        <input type="text" name="city" value="<%= @city %>"
               placeholder="City"
               autocomplete="off"
               list="matches"
               phx-debounce="1000"
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
        <div class="loader">Loading</div>
      <% end %>

      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li>
              <div class="first-line">
                <div class="name">
                  <%= store.name %>
                </div>
                <div class="status">
                  <%= if store.open do %>
                    <span class="open">Open</span>
                  <% else %>
                    <span class="closed">Closed</span>
                  <% end %>
                </div>
              </div>
              <div class="second-line">
                <div class="street">
                  <img src="images/location.svg">
                  <%= store.street %>
                </div>
                <div class="phone_number">
                  <img src="images/phone.svg">
                  <%= store.phone_number %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    socket =
      assign(
        socket,
        zip: zip,
        stores: [],
        loading: true
      )
    send(self(), {:run_zip_search, zip})

    {:noreply, socket}
  end

  def handle_event("suggest-city", %{"city" => prefix}, socket) do
    socket = assign(socket, city: prefix, matches: Cities.suggest(prefix))
    {:noreply, socket}
  end

  def handle_event("city-search", %{"city" => city}, socket) do
    socket =
      assign(
        socket,
        city: city,
        stores: [],
        loading: true
      )
    send(self(), {:run_city_search, city})
    {:noreply, socket}
  end

  def handle_info({:run_zip_search, zip}, socket) do
    # socket = assign(
    #   socket,
    #   stores: Stores.search_by_zip(zip),
    #   loading: false
    # )
    # {:noreply, socket}
    case Stores.search_by_zip(zip) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No stores matching \"#{zip}\"")
          |> assign(stores: [], loading: false)
        {:noreply, socket}
      stores ->
        socket =
          socket
          |> clear_flash
          |> assign(stores: stores, loading: false)
        {:noreply, socket}
    end
  end

  def handle_info({:run_city_search, city}, socket) do
    case Stores.search_by_city(city) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No stores matching \"#{city}\"")
          |> assign(stores: [], loading: false)
        {:noreply, socket}
      stores ->
        socket =
          socket
          |> clear_flash
          |> assign(stores: stores, loading: false)
        {:noreply, socket}
    end
  end
end