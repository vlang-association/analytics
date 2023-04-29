const currentUrl = window.location.href
if (window.location.hostname !== 'localhost') {
    fetch('https://vosca.dev/a', {
        method: 'POST',
        body: JSON.stringify({
            url: currentUrl,
        })
    }).catch(e => {
        console.log(e)
    })
}
