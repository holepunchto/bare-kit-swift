const chunk = Buffer.alloc(1024)

let remaining = 4096

function write() {
  while (remaining > 0) {
    remaining--

    if (!Bare.IPC.write(chunk)) return Bare.IPC.once('drain', write)
  }

  Bare.exit(0)
}

write()
