const express = require("express")
const cors = require("cors")
const helmet = require("helmet")
const pkg = require("./package.json")

const app = express()

app.get("/", express.static("public"))

app.get('/version', (req, res) => {
    res.json(pkg.version)
})

app.get('/all', (req, res) => {
    res.json(pkg)
})

app.get('/ip', (req, res) => {
    res.send("Your IP is " +  req.ip)
})

app.get("/health", (req, res) => {
    res.send("OK")
})

app.listen(80, () => {
    console.log("Hmmmmm.....")
})