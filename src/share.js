let openShare = document.getElementById("open-share");
console.log(openShare);
openShare.addEventListener("click", () => {
  console.log("clck");
  document.getElementById("share-box").classList.toggle("hidden");
  openShare.classList.toggle("open");
});
