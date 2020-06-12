var foo = {

}

var obj = {
    deviceStatus:  '0',
    planType:      'Lifetime',
    subscriptions:  foo
  };

var str = JSON.stringify(obj)

$done({ body: str, status: 200 });
