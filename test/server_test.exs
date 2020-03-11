defmodule ServerTest do
  use ExUnit.Case

  test "recieves sent message" do
    message = "sent message"
    Server.start_link
    Server.send_message(message)
    assert Server.get_messages == [message, "I ran init"]
  end

  test "start new room" do
    message = "this is a message"
    Server.send_message(message)
    assert Server.get_messages == [message, "I ran init"]
  end
end
