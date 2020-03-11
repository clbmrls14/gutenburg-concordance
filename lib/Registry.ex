defmodule Registry do
  use GenServer
  @word_list :word_server

  def start_link(server \\ @word_list) do
    case (GenServer.whereis(server)) do
      nil ->
        GenServer.start_link(__MODULE__, %WordList{words: []}, name: server)
      pid ->
        {@word_list, pid}
    end
  end

  def register(new_word) do
    GenServer.cast(@word_list, {:register, new_word})
  end

  def get_words(server \\ @word_list) do
    GenServer.call(server, :get_words)
  end

  #--------------------------------------------------
  #--------------- Server Side ----------------------
  #--------------------------------------------------

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_cast({:register, word}, state) do
    new_word_list = %WordList{words: [word | state.words]}
    {:noreply, new_word_list}
  end

  @impl true
  def handle_call(:get_words, _from, state) do
    {:reply, state.words, state}
  end
end
