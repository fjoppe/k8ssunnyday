import express, { application } from 'express';
import csv from "csv-parser";
import fs from "fs";

const app = express();
app.use(express.json());
const port = 3000;

const data = [];

fs.createReadStream("./country-codes.csv")
  .pipe(csv())
  .on('data', (row) => data.push(row))
  .on('end', () => {
    console.log(data);
  })


app.get('/fifa/:fifa', (req, res) => {
  console.log(`GET /fifa/${req.params?.fifa?.toLowerCase() ?? "null"}`);
  const row = data.find(row => row.FIFA.toLowerCase() === req.params.fifa.toLowerCase());
  if(row !== null){
    res.send(JSON.stringify(row));
  } else {
    res.send('{"error": "FIFA not found"}');
  }
});

app.listen(port, () => {
  return console.log(`Express is listening at http://localhost:${port}`);
});
