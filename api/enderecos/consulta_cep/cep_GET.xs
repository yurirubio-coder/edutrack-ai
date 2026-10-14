query "consultaCep/{cep}" verb=GET {
  api_group = "Endereços"

  input {
    text cep
  }

  stack {
    var $clean_cep {
      value = "/[^0-9]/"|regex_replace:"":$input.cep
    }
  
    api.request {
      url = "https://viacep.com.br/ws/" ~ ($clean_cep|to_text) ~ "/json/"
      method = "GET"
    } as $viacep
  
    var $is_success {
      value = (($viacep.response.status) == 200) && !($viacep.response.result|has:"erro")
    }
  
    conditional {
      if ($is_success) {
        var $result {
          value = {
            status  : true
            endereco: {
              cep: $viacep.response.result.cep,
              logradouro: $viacep.response.result.logradouro,
              complemento: $viacep.response.result.complemento,
              unidade: $viacep.response.result.unidade,
              bairro: $viacep.response.result.bairro,
              localidade: $viacep.response.result.localidade,
              uf: $viacep.response.result.uf,
              estado: $viacep.response.result.estado,
              regiao: $viacep.response.result.regiao,
              ibge: $viacep.response.result.ibge,
              gia: $viacep.response.result.gia,
              ddd: $viacep.response.result.ddd,
              siafi: $viacep.response.result.siafi
            }
          }
        }
      }
    
      else {
        var $result {
          value = {status: false, endereco: null}
        }
      }
    }
  }

  response = $result
  guid = "0J4O0q30uMxWiVKGe-b-MJullJw"
}