let fadeTimout = 1000 * 10;
let timeout = window.setTimeout(() => {
  document.body.classList.add("faded");
}, fadeTimout);

let handleActivity = e => {
  window.clearTimeout(timeout);
  document.body.classList.remove("faded");
  timeout = window.setTimeout(() => {
    document.body.classList.add("faded");
  }, fadeTimout);
};
document.body.addEventListener("mousemove", handleActivity);
document.body.addEventListener("keydown", handleActivity);
document.body.addEventListener("touchstart", handleActivity);

module.exports = handleActivity;
