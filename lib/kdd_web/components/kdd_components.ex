defmodule KddWeb.KddComponents do
  use Phoenix.Component

  slot :inner_block

  def heading(assigns) do
    ~H"""
    <div class="flex space-between">
      <div class="flex-grow w-auto">
        <h1 class="text-2xl font-semilbold">
          <%= render_slot(@inner_block) %>
        </h1>
      </div>
    </div>
    """
  end

  attr :date, :map
  def notion_date(assigns) do
    %{
      "array" => [
        %{
          "date" => %{
            "end" => end_date,
            "start" => start_date,
            "time_zone" => _tz
          },
          "type" => "date"
        }
      ]
    } = assigns.date

    assigns = assign(assigns, :start_date, start_date)
    assigns = assign(assigns, :end_date, end_date)

    if is_nil(end_date) do
      ~H"""
      <%= @start_date %>
      """
    else
      ~H"""
      <%= @start_date %> until <%= @end_date %>
      """
    end
  end

  attr :title, :map
  def notion_title(assigns) do
    %{
      "array" => [
        %{
          "title" => [
            %{
              "href" => _href,
              "plain_text" => plain_text,
              "text" => _text,
              "type" => "text"
            }
          ],
          "type" => "title"
        }
      ]
    } = assigns.title

    assigns = assign(assigns, :plain_text, plain_text)

    ~H"""
    <%= @plain_text %>
    """
  end
end
