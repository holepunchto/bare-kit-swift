const chunks = []

Bare.IPC.on('data', (data) => chunks.push(data)).on('end', () =>
  Bare.IPC.end(Buffer.concat(chunks))
)
