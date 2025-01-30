var socket = new WebSocket("ws://192.168.1.152:5580/ws");
socket.addEventListener("message", (event) => {
  console.log("Message from server ", event.data);
});

socket.addEventListener("open", (event) => {
  console.log("WebSocket is open");
  var message = {
    message_id: "1",
    command: "set_thread_dataset",
    args: {
      dataset:
        "0e080000000000010000000300000f4a0300000c35060004001fffe0020842ba4b9c13d62bdd0708fd14f7a80c33af9905101058efe407e3ad18e03e39e0c677c25b030e68612d7468726561642d643636620102d66b0410b191a75e1b338a4b7f2d58ec98876c5c0c0402a0f7f8",
    },
  };
  socket.send(JSON.stringify(message));
});

u;

var socket = new WebSocket("ws://192.168.1.152:5580/ws");
socket.addEventListener("message", (event) => {
  console.log("Message from server ", event.data);
});
socket.addEventListener("open", (event) => {
  console.log("WebSocket is open");
  var message = {
    message_id: "2",
    command: "commission_with_code",
    args: {
      code: "15548010418",
    },
  };
  socket.send(JSON.stringify(message));
});
