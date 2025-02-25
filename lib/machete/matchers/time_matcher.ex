defmodule Machete.TimeMatcher do
  @moduledoc """
  Defines a matcher that matches Time values
  """

  import Machete.Mismatch

  defstruct precision: nil, exactly: nil, roughly: nil, before: nil, after: nil

  @typedoc """
  Describes an instance of this matcher
  """
  @opaque t :: %__MODULE__{}

  @typedoc """
  Describes the arguments that can be passed to this matcher
  """
  @type opts :: [
          {:precision, 0..6},
          {:exactly, Time.t()},
          {:roughly, Time.t() | :now},
          {:before, Time.t() | :now},
          {:after, Time.t() | :now}
        ]

  @doc """
  Matches against Time values

  Takes the following arguments:

  * `precision`: Requires the matched Time to have the specified microsecond precision
  * `exactly`: Requires the matched Time to be exactly equal to the specified Time
  * `roughly`: Requires the matched Time to be within +/- 10 seconds of the specified Time. The
    atom `:now` can be used to use the current time as the specified Time
  * `before`: Requires the matched Time to be before or equal to the specified Time. The atom
    `:now` can be used to use the current time as the specified Time
  * `after`: Requires the matched Time to be after or equal to the specified Time. The atom `:now`
    can be used to use the current time as the specified Time

  Examples:

      iex> assert Time.utc_now() ~> time()
      true

      iex> assert Time.utc_now() ~> time(precision: 6)
      true

      iex> assert ~T[00:00:00.000000] ~> time(exactly: ~T[00:00:00.000000])
      true

      iex> assert Time.utc_now() ~> time(roughly: :now)
      true

      iex> assert ~T[00:00:00.000000] ~> time(roughly: ~T[00:00:05.000000])
      true

      iex> assert ~T[00:00:00.000000] ~> time(before: :now)
      true

      iex> assert ~T[00:00:00.000000] ~> time(before: ~T[00:00:01.000000])
      true

      iex> assert ~T[23:59:59.999999] ~> time(after: :now)
      true

      iex> assert ~T[00:00:01.000000] ~> time(after: ~T[00:00:00.000000])
      true
  """
  @spec time(opts()) :: t()
  def time(opts \\ []), do: struct!(__MODULE__, opts)

  defimpl Machete.Matchable do
    def mismatches(%@for{} = a, b) do
      with nil <- matches_type(b),
           nil <- matches_precision(b, a.precision),
           nil <- matches_exactly(b, a.exactly),
           nil <- matches_roughly(b, a.roughly),
           nil <- matches_before(b, a.before),
           nil <- matches_after(b, a.after) do
      end
    end

    defp matches_type(%Time{}), do: nil
    defp matches_type(b), do: mismatch("#{safe_inspect(b)} is not a Time")

    defp matches_precision(_, nil), do: nil
    defp matches_precision(%Time{microsecond: {_, precision}}, precision), do: nil

    defp matches_precision(%Time{microsecond: {_, b_precision}} = b, precision),
      do: mismatch("#{safe_inspect(b)} has precision #{b_precision}, expected #{precision}")

    defp matches_exactly(_, nil), do: nil

    defp matches_exactly(b, exactly) do
      if Time.diff(b, exactly, :microsecond) != 0 do
        mismatch("#{safe_inspect(b)} is not equal to #{safe_inspect(exactly)}")
      end
    end

    defp matches_roughly(_, nil), do: nil
    defp matches_roughly(b, :now), do: matches_roughly(b, Time.utc_now())

    defp matches_roughly(b, roughly) do
      if Time.diff(b, roughly, :microsecond) not in -10_000_000..10_000_000 do
        mismatch("#{safe_inspect(b)} is not within 10 seconds of #{safe_inspect(roughly)}")
      end
    end

    defp matches_before(_, nil), do: nil
    defp matches_before(b, :now), do: matches_before(b, Time.utc_now())

    defp matches_before(b, before) do
      if Time.compare(b, before) != :lt do
        mismatch("#{safe_inspect(b)} is not before #{safe_inspect(before)}")
      end
    end

    defp matches_after(_, nil), do: nil
    defp matches_after(b, :now), do: matches_after(b, Time.utc_now())

    defp matches_after(b, after_var) do
      if Time.compare(b, after_var) != :gt do
        mismatch("#{safe_inspect(b)} is not after #{safe_inspect(after_var)}")
      end
    end
  end
end
