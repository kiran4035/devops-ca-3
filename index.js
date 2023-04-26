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
    allowedHeaders: ["*"]
}))

app.use((req, res, next) => {
    if (/(.ico|.js|.css|.jpg|.png|.map)$/i.test(req.path)) {
        next();
    } else {
        res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
        res.header('Expires', '-1');
        res.header('Pragma', 'no-cache');
        res.sendFile(path.join(__dirname, 'public', 'index.html'));
    }
});
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