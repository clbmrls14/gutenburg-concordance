defmodule Server do
  use GenServer

  def start_link(word) do
    case (GenServer.whereis(String.to_atom(word))) do
      nil ->
        GenServer.start_link(__MODULE__, %Word{word: word}, name: String.to_atom(word))
        {:ok, word}
      pid ->
        {word, pid}
    end
  end

  def add_word(word, location) do
    Server.start_link(word)
    GenServer.cast(String.to_atom(word), {:add_word, location})
  end

  def get_state(word) do
    #Server.start_link(word)
    GenServer.call(word, :get_state)
  end

  #--------------------------------------------------
  #--------------- Server Side ----------------------
  #--------------------------------------------------

  @impl true
  def init(initial_state) do
    Registry.register(initial_state.word)
    #IO.puts("Registering "<>initial_state.word)

    {:ok, initial_state}
  end

  @impl true
  def handle_cast({:add_word, location}, word_struct) do
    new_word_struct = %Word{word: word_struct.word, locations: [location | word_struct.locations] }
    {:noreply, new_word_struct}
  end

  @impl true
  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

end
