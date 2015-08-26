pm2 stop kpi
git checkout -- .
git pull origin master
pm2 start app.js --name kpi -- --prod