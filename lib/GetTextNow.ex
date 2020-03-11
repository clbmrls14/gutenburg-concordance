defmodule GetTextNow do

  def run(start_index, end_index) do
    #url = "https://www.gutenberg.org/files/#{book.id}/#{book.id}-0.txt"
    # url = "https://dev.gutenberg.org/files/204/204.txt"
    Registry.start_link()
    Task.async_stream(start_index..end_index,  fn i -> go_get_it("https://www.gutenberg.org/files/#{i}/#{i}.txt") end, timeout: 12000)
    |> Enum.map(fn {:ok, result} -> result end)
    print_report()

  end

  def go_get_it(url) do
    HTTPoison.start
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          [title | _] = String.split(body, "\r\n\r\n")
          IO.inspect(title)
          body
          |> String.upcase(:ascii)
          |> String.split([".", ",", "?", "!", ":", ";", "_", "\"", " ", "\r", "\n", "=", ")", "(", "[", "]",
          "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "--", "/", "*"], trim: true)
          |> Enum.reduce(0, fn word, offset ->
            location = %Location{book_title: title, location: offset}
            Server.add_word(word, location)
            offset + 1
          end)

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts "Page not found"

        {:ok, %HTTPoison.Response{status_code: 402}} ->
          IO.puts "Error or something"

        {:ok, %HTTPoison.Error{reason: reason}} ->
          IO.puts reason

      end
  end

  def print_report do
    results = Enum.map(Registry.get_words(), fn w ->
      Server.get_state(String.to_atom(w))
    end)

    {:ok, file} = File.open("output.txt")

    file = "output.txt"
    File.write(file, "*************************\n")
    File.write(file, "****** Concordance ******\n", [:append])
    File.write(file, "*************************\n\n", [:append])

    Enum.map(results, fn i ->
      File.write(file, "name: #{i.word}\n", [:append])
      File.write(file, "#{Enum.count(i.locations)} occurances\n", [:append])
      Enum.map(Enum.take(i.locations, 5), fn j ->
        this_loc = Integer.to_string(j.location)
        File.write(file, "\tBook: #{j.book_title}, Offset: #{this_loc}\n", [:append])
      end)
      File.write(file, "\n", [:append])
    end)
    File.write(file, "\n\n\t\t### END CONCORDANCE ###\n", [:append])

    # file = "output.txt"
    # File.write(file, "*************************\n")
    # File.write(file, "****** Concordance ******\n", [:append])
    # File.write(file, "*************************\n\n", [:append])

    # Enum.map(results, fn i ->
    #   File.write(file, "name: #{i.word}\n", [:append])
    #   File.write(file, "#{Enum.count(i.locations)} occurances\n", [:append])
    #   Enum.map(Enum.take(i.locations, 5), fn j ->
    #     this_loc = Integer.to_string(j.location)
    #     File.write(file, "\tBook: #{j.book_title}, Offset: #{this_loc}\n", [:append])
    #   end)
    #   File.write(file, "\n", [:append])
    # end)
    # File.write(file, "\n\n\t\t### END CONCORDANCE ###\n", [:append])
  end
end
