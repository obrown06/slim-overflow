defmodule PlungerWeb.ViewHelpers do
  def current_user(conn), do: Coherence.current_user(conn)


  @months %{
    1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr",
    5 => "May", 6 => "Jun", 7 => "Jul", 8 => "Aug",
    9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dec"
  }

  def format_time(date_time) do
    month = Map.get(@months, date_time.month)
    day = Integer.to_string(date_time.day)
    year = "'" <> Integer.to_string(rem(date_time.year, 2000))
    hour = Integer.to_string(date_time.hour)
    minute = Integer.to_string(date_time.minute)

    month <> " " <> day <> " " <> year <> " at " <> hour <> ":" <> minute
  end

  def format_date(date_time) do
    month = Map.get(@months, date_time.month)
    day = Integer.to_string(date_time.day)
    year = "'" <> Integer.to_string(rem(date_time.year, 2000))
    hour = Integer.to_string(date_time.hour)
    minute = Integer.to_string(date_time.minute)

    month <> " " <> day <> " " <> year
  end

  def naive_date_time_compare(time1, time2) do
    case NaiveDateTime.compare(time1, time2) do
      :lt -> true
      :eq -> true
      :gt -> false
      _ -> raise "This shouldn't happen"
    end
  end
end
