defmodule Word do
  defstruct word: nil,
            locations: []
end

defmodule Location do
  defstruct book_title: nil,
            location: 0
end

defmodule WordList do
  defstruct words: []
end
