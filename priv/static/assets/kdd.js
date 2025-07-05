window.addEventListener("load", function(e) {
    let timestamps = Array.from(document.getElementsByClassName("kdd_timestamp"));
    timestamps.forEach(element => {
        utc = element.innerHTML;
        dt = new Date(Date.parse(utc));
        element.innerHTML = dt.toLocaleString();
    });
});