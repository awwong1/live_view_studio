defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      brightness: 10,
      temp: 3000
    )
    IO.inspect(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%; background-color: <%= temp_color(@temp) %>;">
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="images/light-off.svg"/>
      </button>
      <button phx-click="down">
        <img src="images/down.svg"/>
      </button>
      <button phx-click="up">
        <img src="images/up.svg"/>
      </button>
      <button phx-click="on">
        <img src="images/light-on.svg"/>
      </button>
      <button phx-click="lmu">
        <span>Light me up!</span>
      </button>
      <form phx-change="update">
        <input type="range" min="0" max="100" name="brightness" value="<%= @brightness %>">
      </form>
      <form phx-change="temp-change">

      <%= for temp <- [ "3000", "4000", "5000" ] do %>
        <%= temp_radio_button(%{temp: temp, checked: temp == @temp}) %>
      <% end %>

      </form>
    </div>
    """
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max((&1 - 10), 0))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    # brightness = socket.assigns.brightness + 10
    # socket = assign(socket, brightness: brightness)
    socket = update(socket, :brightness, &min((&1 + 10), 100))
    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("lmu", _, socket) do
    brightness = :rand.uniform(100)
    socket = assign(socket, brightness: brightness)
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    brightness = String.to_integer(brightness)
    socket = assign(socket, brightness: brightness)
    {:noreply, socket}
  end

  def handle_event("temp-change", %{"temp" => temp}, socket) do
    temp = String.to_integer(temp)
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"

  defp temp_radio_button(assigns) do
    ~L"""
    <input type="radio" id="<%= @temp %>"
        name="temp" value="<%= @temp %>"
        <%= if @checked, do: "checked" %> />
    <label for="<%= @temp %>"><%= @temp %></label>
    """
  end
end
