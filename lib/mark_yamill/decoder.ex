defprotocol MarkYamill.Decoder do
  def decode(data)
end

defimpl MarkYamill.Decoder, for: List do
  def decode(list) do
    if :io_lib.printable_list(list) do
      to_string(list)
    else
      for i <- list do
        MarkYamill.Decoder.decode(i)
      end
    end
  end
end
