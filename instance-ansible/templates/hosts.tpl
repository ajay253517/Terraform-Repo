[dbservers]
%{ for ip in dbservers ~}
${ip}
%{ endfor ~}

[webservers]
%{ for ip in webservers ~}
${ip}
%{ endfor ~}
