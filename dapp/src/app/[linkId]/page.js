"use client";
import { useEffect, useState } from "react";
import { useParams} from "next/navigation";
import { getLink, payLink } from "@/services/Web3Service";

export default function LinkId() {
  const params = useParams();

  const [message, setMessage] = useState("");
  const [link, setLink] = useState({fee: "0"});

  useEffect(()=>{
    setMessage("Buscando dados do link... aguarde...");
    getLink({linkId:params.linkId})
      .then(link => {
          setMessage("")
          if(link.url)
            window.location.href = link.url
          else
            setLink(link)
      })
      .catch(err => setMessage(err.message))
  },[])

  function btnAccessClick() {
    payLink(params.linkId, link.fee)
      .then(()=>{
        setMessage("Pagamento realizado... redirecionando...");
        return getLink(params.linkId);
      })
      .then(link => window.location.href = link.url)
      .catch(err => setMessage(err.message))
  }

  return (
    <>
      <div className="container px-4 py-5">
        <div className="row flex-lg-row-reverse align-items-center g-5 py-5">
          <div className="col-6">
            <img src="https://cdn.wikimg.net/en/zeldawiki/images/thumb/9/91/EoW_Hylian_Shield_Model.png/274px-EoW_Hylian_Shield_Model.png" className="d-block mx-lg-auto img-fluid" width="700" height="500"/>
          </div>
          <div className="col-6">
            <h1 className="display-5 fw-bold text-body-emphasis lh-1 mb-3">Link Protegido</h1>
            <p className="lead">Este link está protegido pela LinkShield.</p>
            <hr/>
            <p>Para acessaro conteúdo original, conecte sua carteira abaixo e confirme o pagamento da taxa de <strong>{link.fee} wie</strong>.</p>
           
            <div className="row mb-3">
              <div className="col-6">
                <button type="button" className="btn btn-primary w-100 h-100" onClick={btnAccessClick}>
                  <img src="https://upload.wikimedia.org/wikipedia/commons/3/36/MetaMask_Fox.svg" width="32" className="me-2" />
                  Pagar e acessar Link.
                </button>
              </div>
            </div>
            {message ?
              <div className="alert alert-success p-3 col-12 mt3">{message}</div>
            :
              <></>
            }
          </div>
        </div>
      </div>
    </>
  );
}
