let Question = {

  init(socket, element){ if(!element){ return }
    let questionId  = element.getAttribute("data-id")
    socket.connect()
    this.onReady(questionId, socket)
  },

  onReady(questionId, socket){
    let msgContainer      = document.getElementById("msg-container")
    let msgInput          = document.getElementById("msg-input")
    let postButton        = document.getElementById("msg-submit")
    let questionChannel   = socket.channel("question:" + questionId)

    postButton.addEventListener("click", e => {
      let payload = {body: msgInput.value}
      questionChannel.push("new_msg", payload)
                .receive("error", e => console.log(e) )
      msgInput.value = ""
    })

    questionChannel.on("new_msg", (resp) => {
      this.renderMessage(msgContainer, resp)
    })

    questionChannel.join()
      .receive("ok", resp => console.log("joined the question channel", resp) )
      .receive("error", reason => console.log("join failed", reason) )
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderMessage(msgContainer, {user, body}){
    let template = document.createElement("div")

    template.innerHTML = `
      <b>${this.esc(user)}</b>: ${this.esc(body)}
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  }
}
export default Question
