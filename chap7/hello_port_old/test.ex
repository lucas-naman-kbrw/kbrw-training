HelloPort.start_link
HelloPort.call :hello
HelloPort.call :what
HelloPort.cast {:kbrw, 42}
HelloPort.call :kbrw
HelloPort.call :kbrw
