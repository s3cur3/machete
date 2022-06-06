defmodule ExMatchers.DateTimeMatcher do
  defstruct precision: nil

  def datetime(opts \\ []) do
    %__MODULE__{
      precision: Keyword.get(opts, :precision)
    }
  end

  defimpl ExMatchers.Matchable do
    def mismatches(%ExMatchers.DateTimeMatcher{} = a, b) do
      matches_type(b) ++ matches_precision(b, a.precision)
    end

    defp matches_type(%DateTime{}), do: []
    defp matches_type(b), do: [%ExMatchers.Mismatch{message: "#{inspect(b)} is not a DateTime"}]

    defp matches_precision(_, nil), do: []
    defp matches_precision(%{microsecond: {_, precision}}, precision), do: []
    defp matches_precision(_, _), do: [%ExMatchers.Mismatch{message: "Precision does not match"}]
  end
end
