function communicate(cmd; stdin::IO, stdout::IO)
    inpipe = Pipe()
    outpipe = Pipe()
    @sync begin
        proc = run(
            pipeline(cmd; stdin = inpipe, stdout = outpipe, stderr = stderr);
            wait = false,
        )
        close(outpipe.in)
        try
            @async write(stdout, outpipe)
            try
                write(inpipe, stdin)
            finally
                close(inpipe)
            end
            wait(proc)
        catch
            close(outpipe)
            close(inpipe)
            rethrow()
        end
    end
end
