defmodule ScaleGenerator do
  @notes ~w(C C# D D# E F F# G G# A A# B)
  @flat_chromatic ~w(A Bb B C Db D Eb E F Gb G Ab)
  @doc """
  Find the note for a given interval (`step`) in a `scale` after the `tonic`.

  "m": one semitone
  "M": two semitones (full tone)
  "A": augmented second (three semitones)

  Given the `tonic` "D" in the `scale` (C C# D D# E F F# G G# A A# B C), you
  should return the following notes for the given `step`:

  "m": D#
  "M": E
  "A": F
  """
  @spec step(scale :: list(String.t()), tonic :: String.t(), step :: String.t()) ::
          String.t()
  def step(scale, tonic, "m"), do: step_number(scale, tonic, 1)
  def step(scale, tonic, "M"), do: step_number(scale, tonic, 2)
  def step(scale, tonic, "A"), do: step_number(scale, tonic, 3)

  def step_number(scale, tonic, step) do
    note_index =
      scale
      |> Enum.find_index(&(&1 == tonic))
      |> Kernel.+(step)
      |> rem(length(scale))

    {:ok, note} = Enum.fetch(scale, note_index)
    note
  end

  @doc """
  The chromatic scale is a musical scale with thirteen pitches, each a semitone
  (half-tone) above or below another.

  Notes with a sharp (#) are a semitone higher than the note below them, where
  the next letter note is a full tone except in the case of B and E, which have
  no sharps.

  Generate these notes, starting with the given `tonic` and wrapping back
  around to the note before it, ending with the tonic an octave higher than the
  original. If the `tonic` is lowercase, capitalize it.

  "C" should generate: ~w(C C# D D# E F F# G G# A A# B C)
  """
  @spec chromatic_scale(tonic :: String.t()) :: list(String.t())
  def chromatic_scale(tonic \\ "C") do
    scale(tonic, "mmmmmmm")
  end

  @doc """
  Sharp notes can also be considered the flat (b) note of the tone above them,
  so the notes can also be represented as:

  A Bb B C Db D Eb E F Gb G Ab

  Generate these notes, starting with the given `tonic` and wrapping back
  around to the note before it, ending with the tonic an octave higher than the
  original. If the `tonic` is lowercase, capitalize it.

  "C" should generate: ~w(C Db D Eb E F Gb G Ab A Bb B C)
  """
  @spec flat_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def flat_chromatic_scale(tonic \\ "C") do
  end

  @doc """
  Certain scales will require the use of the flat version, depending on the
  `tonic` (key) that begins them, which is C in the above examples.

  For any of the following tonics, use the flat chromatic scale:

  F Bb Eb Ab Db Gb d g c f bb eb

  For all others, use the regular chromatic scale.
  """

  @spec find_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def find_chromatic_scale(tonic) do
  end

  @doc """
  The `pattern` string will let you know how many steps to make for the next
  note in the scale.

  For example, a C Major scale will receive the pattern "MMmMMMm", which
  indicates you will start with C, make a full step over C# to D, another over
  D# to E, then a semitone, stepping from E to F (again, E has no sharp). You
  can follow the rest of the pattern to get:

  C D E F G A B C
  """
  @spec scale(tonic :: String.t(), pattern :: String.t()) :: list(String.t())
  def scale(tonic_dubious_case, pattern, notes \\ @notes) do
    sharpened_notes = sharpen_scale(notes)

    tonic =
      tonic_dubious_case
      |> String.upcase()
      |> sharpen()

    start_fun = fn -> [tonic] end
    end_fun = fn x -> x end

    reducer = fn interval, [current | _] = acc ->
      log(interval)
      log(current)

      next_note = step(sharpened_notes, current, interval)
      log(next_note)
      result = [next_note | acc]
      log(result)

      if next_note == tonic do
        {:halt, result}
      else
        {[next_note], result}
      end
    end

    middle =
      pattern
      |> String.codepoints()
      |> Stream.cycle()
      |> Stream.transform(start_fun, reducer, end_fun)
      |> Enum.to_list()

    [tonic | middle] ++ [tonic]
  end

  defp log(something) do
    IO.puts(inspect(something))
  end

  def next_note(note, amount) do
    major_note = String.first(note)

    index =
      @notes
      |> Enum.find_index(&(&1 == String.first(major_note)))

    @notes
    |> Enum.fetch!(rem(index + amount, length(@notes)))
  end

  def sharpen(str) do
    first = String.first(str)

    case String.last(str) do
      "b" ->
        next_note(first, -1)

      _ ->
        str
    end
  end

  def flatten(str) do
    first = String.first(str)

    case String.last(str) do
      "b" ->
        next_note(first, 2)

      _ ->
        str
    end
  end

  def sharpen_scale(scale) do
    Enum.map(scale, fn note -> sharpen(note) end)
  end
end
