var obj = {
  featId: '',
  registered: true,
  expDate: '2333-10-01',
  key: ''
};

var str = JSON.stringify(obj);

$done({ body: str, status: 200 });
