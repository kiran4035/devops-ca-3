const express = require("express")
const cors = require("cors")
const helmet = require("helmet")
const morgan = require("morgan")
const pkg = require("./package.json")
const path = require("path")
const app = express()

app.use(morgan('dev'))
app.use(helmet())
app.use(cors({
    "origin": "weather.b68dev.xyz"    
))

app.use(express.static(path.join(__dirname, 'public')));

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
