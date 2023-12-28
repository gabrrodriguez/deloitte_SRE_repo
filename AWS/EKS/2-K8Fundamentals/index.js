const express = require("express")
const app = express()

const PORT = process.env.PORT || 3000

app.get('/', (req, res)=> {
    res.send('Hello World from inside Docker Container.')
})

app.listen(PORT, ()=> {
    console.log(`App is up and listening on port ${PORT}`)
})