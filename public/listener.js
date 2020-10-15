let socket = io.connect(document.location.href);

socket.on("soundLevels", (data) => {
  const log = document.querySelector("pre");
  log.textContent = `${data}\n${log.textContent}`;
});
