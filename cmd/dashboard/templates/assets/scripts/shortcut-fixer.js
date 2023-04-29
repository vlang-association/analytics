document.addEventListener("DOMContentLoaded", () => {
    const ctrlKey = document.querySelector(".ctrl-key");
    const platform = navigator.platform.toLowerCase();
    if (platform.includes("mac") || platform.includes("ios")) {
        ctrlKey.textContent = "⌘";
    }
});
