defmodule PlungerWeb.ViewHelpers do
  def current_user(conn), do: Coherence.current_user(conn)


  @months %{
    1 => "January", 2 => "February", 3 => "March", 4 => "April",
    5 => "May", 6 => "June", 7 => "July", 8 => "August",
    9 => "September", 10 => "October", 11 => "November", 12 => "December"
  }

  def get_time_posted(date_time) do
    month = Map.get(@months, date_time.month)
    day = Integer.to_string(date_time.day)
    year = Integer.to_string(date_time.year)
    hour = Integer.to_string(date_time.hour)
    minute = Integer.to_string(date_time.minute)

    month <> " " <> day <> "th, " <> year <> " at " <> hour <> ":" <> minute
  end
end
