document.addEventListener("DOMContentLoaded", function() {
  const githubStars = document.querySelectorAll(".github-star");
  githubStars.forEach(function(starElement) {
    const repo = starElement.getAttribute("original");
    fetch(`https://api.github.com/repos/${repo}`)
      .then(response => response.json())
      .then(data => {
        const starCount = data.stargazers_count;
        starElement.textContent = `★ ${starCount}`;
      })
      .catch(error => {
        console.error("Error fetching GitHub stars:", error);
        starElement.textContent = "无法加载 Stars";
      });
  });
});
